import sys
import os
import re
import requests
from bs4 import BeautifulSoup
from urllib.parse import quote


def search_paper_on_arxiv(title):
    # 代理设置
    proxy_url = "http://127.0.0.1:6789" # TODO: 根据实际情况调整代理
    os.environ['http_proxy'] = proxy_url
    os.environ['https_proxy'] = proxy_url
    os.environ['all_proxy'] = "socks5://127.0.0.1:6789"
    proxies = {"http": proxy_url, "https": proxy_url}

    clean_title = re.sub(r'[:\-\n\r]', ' ', title).strip()
    search_query = " ".join(clean_title.split()[:12])

    encoded_query = quote(search_query)
    search_url = f"https://arxiv.org/search/?query={encoded_query}&searchtype=all&source=header"

    headers = {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
    }
    try:
        response = requests.get(search_url, proxies=proxies, headers=headers, timeout=15)
        response.raise_for_status()
        
        soup = BeautifulSoup(response.text, 'html.parser')

        first_result = soup.find('p', class_='list-title')
        if first_result and first_result.find('a'):
            return first_result.find('a')['href']
        
        all_links = soup.find_all('a', href=re.compile(r'arxiv.org/abs/'))
        if all_links:
            return all_links[0]['href']
            
        return f"No results for: {search_query}"

    except Exception as e:
        return f"Error: {str(e)}"

if __name__ == "__main__":
    if len(sys.argv) > 1:

        input_title = " ".join(sys.argv[1:])
        url = search_paper_on_arxiv(input_title)
        url = url.replace('abs', 'pdf')
        print(input_title + '@' + url)