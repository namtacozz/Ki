import urllib.request
import re
import os

fonts = {
    "Cinzel-Bold.woff2": "https://fonts.googleapis.com/css2?family=Cinzel:wght@700",
    "CormorantGaramond-SemiBold.woff2": "https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@600",
    "SourceSerifPro-Regular.woff2": "https://fonts.googleapis.com/css2?family=Source+Serif+4:wght@400",
    "OpenSans-SemiBold.woff2": "https://fonts.googleapis.com/css2?family=Open+Sans:wght@600",
    "EBGaramond-Regular.woff2": "https://fonts.googleapis.com/css2?family=EB+Garamond:wght@400",
    "Inter-Regular.woff2": "https://fonts.googleapis.com/css2?family=Inter:wght@400",
    "RobotoMono-Regular.woff2": "https://fonts.googleapis.com/css2?family=Roboto+Mono:wght@400"
}

os.makedirs("assets/fonts", exist_ok=True)

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
}

for name, css_url in fonts.items():
    path = os.path.join("assets/fonts", name)
    print(f"Fetching {name} css...")
    try:
        req = urllib.request.Request(css_url, headers=headers)
        with urllib.request.urlopen(req) as response:
            css = response.read().decode('utf-8')
            urls = re.findall(r'url\((https://[^)]+\.woff2)\)', css)
            if urls:
                # Get the last url (usually latin or vietnamese if available)
                # Actually, let's grab the vietnamese one if it exists, else the last one
                target_url = urls[-1]
                for block in css.split('}'):
                    if '/* vietnamese */' in block and 'url(' in block:
                        v_urls = re.findall(r'url\((https://[^)]+\.woff2)\)', block)
                        if v_urls: target_url = v_urls[0]
                
                print(f"Downloading {name} from {target_url}...")
                urllib.request.urlretrieve(target_url, path)
                print(f"Success: {name}")
            else:
                print(f"No woff2 found in CSS for {name}")
    except Exception as e:
        print(f"Failed to process {name}: {e}")
