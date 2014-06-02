#!/usr/bin/env python
#coding: utf-8
import requests
import re
from translator import Translator


class OpenFood(object):

    def __init__(self):
        self.barcode = ''
        self.translator = None

    def update(self, barcode):
        self.barcode = barcode

    def product_info(self):
        url = 'http://nl.openfoodfacts.org/product/{0}'.format(self.barcode)
        r = requests.get(url)
        if 'No product listed for barcode' in r.text:
            return None
        return r.text

    def ingredients(self, translate=True):
        self.translator = Translator()
        product_html = self.product_info()
        if product_html is None:
            return ''
        ingredients_info = re.findall(r'ingredientListAsText">(.*?)</span>', product_html)[0]
        if translate:
            return self.translator.nl2en(ingredients_info)
        return ingredients_info

    def contains(self, keywords):
        ingredients = self.ingredients()
        keywords = keywords.split(',')
        res = dict(ingredients=ingredients, allergen=list())
        if ingredients == '':
            return res
        for keyword in keywords:
            keyword = keyword.strip()
            status = 'Yes' if keyword in ingredients else 'No'
            item = dict(name=keyword, contains=status)
            res['allergen'].append(item)
        return res


def main():
    food = OpenFood()
    #food.update('5000189974593')
    food.update('4770023483161')
    print food.ingredients()

if __name__ == '__main__':
    main()