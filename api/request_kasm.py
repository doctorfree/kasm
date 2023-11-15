import requests
import urllib.parse

# Change the IP to your installation
kasm_api_url = "https://10.240.128.92/api/public"

# Data required for API Call
request_data = {
    "api_key": "__KASM_API_KEY__",
    "api_key_secret": "__KASM_API_SECRET__",
    "image_id": "__DOCKER_IMAGE_ID__",
    "enable_sharing": True # Sharing allows multiple view-only users of the streaming container
}

# Create a new streaming container and get the resulting url
res = requests.post(kasm_api_url + '/request_kasm', json=request_data, verify=False)
res_json = res.json()
print('The stream url of the container is %s' % res_json['kasm_url'])
