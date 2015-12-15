# -*- coding: utf-8 -*-
from __future__ import unicode_literals
import lxml.html
from lxml.cssselect import CSSSelector
import requests
import re, csv, codecs, cStringIO

class UTF8Recoder:
    def __init__(self, f, encoding):
        self.reader = codecs.getreader(encoding)(f)
    def __iter__(self):
        return self
    def next(self):
        return self.reader.next().encode("utf-8")

class UnicodeWriter:
    def __init__(self, f, dialect=csv.excel, encoding="utf-8-sig", **kwds):
        self.queue = cStringIO.StringIO()
        self.writer = csv.writer(self.queue, dialect=dialect, **kwds)
        self.stream = f
        self.encoder = codecs.getincrementalencoder(encoding)()
    def writerow(self, row):
        '''writerow(unicode) -> None
        This function takes a Unicode string and encodes it to the output.
        '''
        self.writer.writerow([s.encode("utf-8") for s in row])
        data = self.queue.getvalue()
        data = data.decode("utf-8")
        data = self.encoder.encode(data)
        self.stream.write(data)
        self.queue.truncate(0)

    def writerows(self, rows):
        for row in rows:
            self.writerow(row)

title_regex = re.compile(u'(^[a-zA-Z0-9\\:ë, ’-]*)\s(\([0-9]{4}\))')

def clean_title(text):
    clean = text.replace('\n', '').strip()
    match = title_regex.search(clean)
    return match.group(1), match.group(2)

def get_title(node):
    h3_elem = node.cssselect('div.feature-item__text h3')[0]
    anchor_elem = h3_elem.cssselect('a')
    if len(anchor_elem) == 0:
        return h3_elem.text_content()
    else:
        return anchor_elem[0].text_content()

def get_top(node):
    div_elem = node.cssselect('div.feature-item__count')[0]
    return div_elem.text_content()

def get_item(node):
    title = get_title(node)
    movie, year = clean_title(title)
    return movie, year, get_top(node)

r = requests.get("http://www.timeout.com/london/film/the-50-best-christmas-movies")
tree = lxml.html.fromstring(r.text)

items_selector = CSSSelector('article.feature-item')
all_items = items_selector(tree)

anchor_sel = CSSSelector('a')
h3_titles = [get_item(item) for item in all_items[0:50]]

with open('movies.csv', mode='wb') as csvfile:
    moviewriter = UnicodeWriter(csvfile, delimiter = '\t', quoting=csv.QUOTE_ALL)
    for item in h3_titles:
        moviewriter.writerow(item)