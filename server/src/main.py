#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json
import re
import utils
from translator import Translator

from flask import Flask
app = Flask(__name__)


@app.route('/')
def hello_world():
    return 'Hello world'


@app.route('/en2nl/<text>')
def en2nl(text):
    api = Translator()
    translated = unicode(api.en2nl(text))
    return utils.json_res(translated)


@app.route('/nl2en/<text>')
def nl2en(text):
    api = Translator()
    translated = unicode(api.nl2en(text))
    return utils.json_res(translated)


@app.route('/translate/<from_lang>/<to_lang>/<text>')
def translate(from_lang, to_lang, text):
    api = Translator()
    translated = unicode(api.translate(from_lang, to_lang, text))
    return utils.json_res(translated)

if __name__ == '__main__':
    app.run(debug=True)
