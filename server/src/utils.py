#!/usr/bin/env python
# -*- coding: utf-8 -*-

from flask import Response
import json

def json_res(res):
    # if res is string, convert it to dict
    if type(res) == unicode:
        res = {
            'result': res
        }
    res = json.dumps(res)
    return Response(res, mimetype='text/json')
