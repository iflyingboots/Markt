#!/usr/bin/env python
# -*- coding: utf-8 -*-

import utils
from translator import Translator
from openfood import OpenFood

from flask import Flask
app = Flask(__name__)

translator = Translator()
food = OpenFood()


@app.route('/')
def hello_world():
    return 'Hello world'


@app.route('/en2nl/<text>')
def en2nl(text):
    translated = unicode(translator.en2nl(text))
    return utils.json_res(translated)


@app.route('/nl2en/<text>')
def nl2en(text):
    translated = unicode(translator.nl2en(text))
    return utils.json_res(translated)


@app.route('/translate/<from_lang>/<to_lang>/<text>')
def translate(from_lang, to_lang, text):
    api = Translator()
    translated = unicode(api.translate(from_lang, to_lang, text))
    return utils.json_res(translated)

@app.route('/ingredients/<barcode>')
def ingredients(barcode):
    food.update(barcode)
    res = food.ingredients()
    return utils.json_res(res)

@app.route('/ingredients/part/<barcode>')
def ingredients_part(barcode):
    food.update(barcode)
    res = food.ingredients()
    res = res.split(',')
    res = [i.strip() for i in res]
    return utils.json_res({"results": res})

@app.route('/contains/<barcode>/<keywords>')
def contains(barcode, keywords):
    food.update(barcode)
    res = food.contains(keywords)
    return utils.json_res(res)

if __name__ == '__main__':
    app.run(debug=True)
