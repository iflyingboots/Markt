#!/usr/bin/env python
# -*- coding: utf-8 -*-
import json
import re
import requests


class Translator:

    def __init__(self):
        self.client_id = 'MarktAPI'
        self.client_secret = 'OvKOkOkZ2XL6XgtwzlKG0L58rC8GHuFJGn4uj1JnOas='
        self.auth_url = 'https://datamarket.accesscontrol.windows.net/v2/OAuth2-13/'

        grant_type = 'client_credentials'
        scope_url = 'http://api.microsofttranslator.com'

        self.payload = {
            'grant_type': grant_type,
            'scope': scope_url,
            'client_id': self.client_id,
            'client_secret': self.client_secret,
        }
        self.get_token()

    def get_token(self):
        req = requests.post(self.auth_url, data=self.payload)
        self.token = json.loads(req.text)
        # print 'Token: %s' % (self.token['access_token'])
        return self.token

    def translate(self, from_lang, to_lang, text):
        if self.token is None:
            return None
        url = 'http://api.microsofttranslator.com/v2/Http.svc/Translate'
        params = {
            'text': text,
            'from': from_lang,
            'to': to_lang,
        }
        headers = {
            'Authorization': 'Bearer ' + self.token['access_token']
        }
        req = requests.get(url, params=params, headers=headers)
        return self.trim_xml(req.text)

    def en2nl(self, text):
        res = self.translate('en', 'nl', text)
        return self.trim_xml(res)

    def nl2en(self, text):
        res = self.translate('nl', 'en', text)
        return self.trim_xml(res)

    def trim_xml(self, text):
        return re.sub(r'<.*?>', '', text)


def main():
    api = Translator()
    text = u"i can eat glass it doesn't hurt me"
    print api.en2nl(text)


if __name__ == '__main__':
    main()
