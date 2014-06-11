#!/usr/bin/env python
# -*- coding: utf-8 -*-
import MySQLdb
from config import *

class DB():

    def __init__(self):
        self.cursor = None
        self.connect()

    def connect(self):
        self.conn = MySQLdb.connect(
            host=MYSQL_HOST,
            user=MYSQL_USERNAME,
            passwd=MYSQL_PASSWORD,
            db=MYSQL_DATABASE,
            charset="utf8"
        )

    def query(self, sql):
        if self.cursor is None:
            self.cursor = self.conn.cursor()
        self.cursor.execute(sql)
        return self.cursor.fetchall()

    def commit(self):
        self.conn.commit()


if __name__ == '__main__':
    db = DB()
    c = db.query('SELECT * FROM items')
    print c