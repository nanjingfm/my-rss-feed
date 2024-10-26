import os
import sys
import feedparser
import feedgenerator
import datetime
import time
import subprocess

def parse_date(date_str):
    if isinstance(date_str, time.struct_time):
        return datetime.datetime(*date_str[:6])
    return date_str

def update_rss(feed_file, url, title):
    # 读取现有的 RSS 文件
    feed = feedparser.parse(feed_file)
    
    # 创建新的 RSS feed
    new_feed = feedgenerator.Rss201rev2Feed(
        title=feed.feed.title,
        link=feed.feed.link,
        description=feed.feed.description,
    )
    
    # 添加新文章
    new_feed.add_item(
        title=title,
        link=url,
        pubdate=datetime.datetime.now(),
        description=title
    )
    
    # 添加现有文章
    for entry in feed.entries:
        new_feed.add_item(
            title=entry.title,
            link=entry.link,
            pubdate=parse_date(entry.published_parsed),
            description=entry.description
        )

    # 写入更新后的 RSS 文件
    with open(feed_file, 'w') as f:
        new_feed.write(f, 'utf-8')
    
    try:
        script_path = os.path.join(os.path.dirname(__file__), 'update_follow_challenge.sh')
        command = [
            'bash',
            script_path,
            feed_file,
            str(feed.feed.get('userid', '')),
            str(feed.feed.get('feedid', ''))
        ]

        subprocess.run(command, check=True, capture_output=True, text=True)
    except subprocess.CalledProcessError as e:
        print(f"执行脚本时出错：\n{e}")
        print(f"错误输出：\n{e.stderr}")
    except Exception as e:
        print(f"发生未知错误：{str(e)}")

if __name__ == '__main__':
    if len(sys.argv) != 4:
        print("Usage: python update_rss.py <url> <title>")
        sys.exit(1)
    
    feed_file = sys.argv[1]
    url = sys.argv[2]
    title = sys.argv[3]
    update_rss(feed_file, url, title)
