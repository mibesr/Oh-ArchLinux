#!/bin/env python
# -*- coding: UTF-8 -*-

# Author: Tsujidou Akari (chiey.qs@gmail.com)
# Date: 08:31 2012/10/07
# Version: 0.5.3

import urllib2
import re
import os
import sqlite3
from subprocess import call
from platform import system

# Variables:
uaHeaders = {'User-Agent':'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.2 (KHTML, like Gecko) Chrome/22.0.1213.0 Safari/537.2'}

if system() != 'Windows':
    #dbFile = '$HOME/Yandere/.dbfile'
    #_authorMemoFile = '$HOME/Yandere/authorMemo.log'
    if not os.path.exists('%s/Yandere' %(os.path.expanduser('~'))):
        os.mkdir('%s/Yandere' %(os.path.expanduser('~')))
    lstFile = '%s/lst.txt' %(os.path.expanduser('~'))
    YandereDIR = '%s/Yandere' %(os.path.expanduser('~'))
else:
    #dbFile = 'D:\\Yandere\\.dbfile'
    #_authorMemoFile = 'D:\\Yandere\\authorMemo.log'
    if not os.path.exists('D:\\Yandere'):
        os.mkdir('D:\\Yandere')
    lstFile = 'D:\\lst.txt'
    YandereDIR = 'D:\\Yandere'

# Classes:
class wait_to_define:
    pass

# Functions:
def fileDownloader(lstImpt):
    cmd_wget = ['wget', '-c', '--no-check-certificate', '--timeout=30', '-i', lstImpt, '-P', YandereDIR]
    subprocess.call(cmd_wget)

#def authorMemo(author):
#    if not os.path.isfile(_authorMemoFile):
#        _authorMemoFileHandle = open(_authorMemoFile, 'w')
#        _authorMemoFileHandle.write(author + ':')
#    else:
#        _authorMemoFileHandle = open(_authorMemoFile, 'a')
#        _authorMemoFileHandle.write(author + ':')
#    _authorMemoFileHandle.close()

def authorChecker(fileHash, imageURL, author):
    cur.execute("SELECT fileHash, author FROM tbl_hash WHERE fileHash=? AND author=?", (fileHash, author))
    if not cur.fetchall():
        _authorLstFileHandle.write(re.sub(r'\\', '', imageURL) + '\n')
        cur.execute("INSERT INTO tbl_hash (fileHash, imageURL, author) values (?, ?, ?)", (fileHash, re.sub(r'\\', '', imageURL), author))
    else:
        print ': �f�[�^�x�[�X�ɂ͂��̉摜�̓����R�[�h[%s]�A�G�t[%s]������܂��̂ŁA�X�L�v���܂�' %(fileHash, author)


def fileChcker(imageURL, fileHash):
    cur.execute("SELECT fileHash FROM tbl_hash WHERE fileHash=?", (fileHash,))
    if not cur.fetchall():
        lstFileHandle.write(re.sub(r'\\', '', imageURL) + '\n')
        cur.execute("INSERT INTO tbl_hash (fileHash, imageURL) values (?, ?)", (fileHash, re.sub(r'\\', '', imageURL)))
    else:
        print ': �f�[�^�x�[�X�ɂ͂��̉摜�̓����R�[�h [%s] ������܂��A�X�L�v���܂�' %fileHash

if __name__ == '__main__':
    # �s���̂��߂ɁA�p�����܂��A���̃t�@�C��
    #if not os.path.isfile(dbFile):
    #    dbFileHandle = open(dbFile, 'w')
    #else:
    #    dbFileHandle = open(dbFile, 'a')
    author = raw_input('�G�t�̖��O�i���[�}���j����͂��ĉ������F ')
    pages = input('���̃N�G�X�g�͂�����̃y�[�W������F ')
    print '\n============================ �_�E�����[�h���J�n���܂� ============================\n'
    if system() != 'Windows':
        conn = sqlite3.connect('%s/Yandere/hashdb.sqlite' %(os.path.expanduser('~')))
    else:
        conn = sqlite3.connect('D:\\Yandere\\hashdb.sqlite')
    cur = conn.cursor()
    cur.execute("CREATE TABLE IF NOT EXISTS tbl_hash (fileHash varchar(32) not null, imageURL varchar, author varchar)")

    if not author:
        lstFileHandle = open(lstFile, 'w')
        #
        for num in range(1, pages + 1):
            print ': \'yande.re\' ������e���擾���Ă��܂�...'
            req = urllib2.Request('https://yande.re/post?page=%s' %(num), headers = uaHeaders)
            res = urllib2.urlopen(req).read()
            print ': ���e����͂��Ă��܂�... ���̓y�[�W %d �ł�\n' %num
            for imageURL in re.findall(r'file_url":"(.+?)"', res):
                fileHash = re.match(r'http.+image\\/(\w+)\\/yande.+', imageURL).group(1)
                fileChcker(imageURL, fileHash)
        #dbFileHandle.close()
        lstFileHandle.close()
        conn.commit()
        conn.close()
        _dl = raw_input('\n: ���ꂩ��摜�̃_�E�����[�h���n�܂�܂��A��낵���ł����H[Y/N]')
        if 'Y' == _dl or 'y' == _dl:
            fileDownloader(lstFile)
        else:
            print ': �X�L�v���܂�'
    else:
        if system() != 'Windows':
            _authorLstFileHandle = open(os.path.expanduser('~') + '/' + author + '.txt', 'w')
        else:
            _authorLstFileHandle = open('D:\\' + author + '.txt', 'w')

        for num in range(1, pages + 1):
            print ': \'yande.re\' ������e���擾���Ă��܂�...'
            req = urllib2.Request('https://yande.re/post?tags=%s&page=%s' %(author, num), headers = uaHeaders)
            res = urllib2.urlopen(req).read()
            print ': ���e����͂��Ă��܂�... ���̓y�[�W %d �ł�\n' %num
            for imageURL in re.findall(r'file_url":"(.+?)"', res):
                fileHash = re.match(r'http.+image\\/(\w+)\\/yande.+', imageURL).group(1)
                authorChecker(fileHash, imageURL, author)
        _authorLstFileHandle.close()
        conn.commit()
        conn.close()

    print '\n============================ ��͂��������܂��� ============================\n'
    raw_input('Press \'Enter\' key to close Window...')

