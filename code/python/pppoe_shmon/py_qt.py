#!/usr/bin/python3
#import threading
import sys
import time
#from PyQt5 import QtWidgets, QtGui, QtCore
from PyQt5.QtCore import *
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
from qt import Ui_MainWindow
#from scapy.all import *
#from threading import Thread
import pppoe
import speed
import datetime
import icmp
import check


####

#####

class Worker(QObject):
    finished = pyqtSignal()
    message = pyqtSignal(str, int)

    @pyqtSlot()
    def process(self):
        print('Press buton PPPoE')
        if application.running:
            application.running=False
            application.ui.pushButton_PPPoE.setText("PPPoE check start")
            application.ui.pushButton_Speedtest.setEnabled(True)
            application.ui.pushButton_Ping.setEnabled(True)
            application.ui.pushButton_Ping2.setEnabled(True)
        else:
            application.running=True
            application.ui.pushButton_PPPoE.setText("PPPoE check stop")
            application.ui.pushButton_Speedtest.setEnabled(False)
            application.ui.pushButton_Ping.setEnabled(False)
            application.ui.pushButton_Ping2.setEnabled(False)

        while application.running:
            application.string = check.check_pppoe()
            if application.string != 0:
                self.message.emit(application.string, 0)
                application.running=False
                application.ui.pushButton_PPPoE.setText("PPPoE check start")
                application.ui.pushButton_Speedtest.setEnabled(True)
                application.ui.pushButton_Ping.setEnabled(True)
                application.ui.pushButton_Ping2.setEnabled(True)
                continue
        
            application.r += 1
            application.L,application.SERVER_LOST_new,application.S_L,application.SERVER_BAD=pppoe.scan()
            application.SERVER_LOST = application.SERVER_LOST+application.SERVER_LOST_new
            print('SERVER_LOST',application.SERVER_LOST)
            print(application.r)
            print(application.L)
            self.message.emit(str(application.SERVER_LOST), 1)
            self.message.emit(str(application.SERVER_BAD), 2)
            if  application.ui.checkBox.isChecked(): application.ui.plainTextEdit.clear()
            self.message.emit('№'+str(application.r), 0)
            application.ui.t=str(datetime.datetime.now())
            self.message.emit(application.ui.t, 0)
            for application.string in application.L:
                self.message.emit(application.string, 0)
            self.message.emit('#'*80, 0)
        self.finished.emit()
        

class mywindow(QMainWindow):
    def __init__(self):
        super(mywindow, self).__init__()
        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)
        self.ui.plainTextEdit.setFont(QFont('SansSerif', 8))
        
        self.ui.pushButton_PPPoE.clicked.connect(self.btnClicked_PPPoE_th)
        self.ui.pushButton_Speedtest.clicked.connect(self.btnClicked_Speedtest)
        self.ui.pushButton_Ping.clicked.connect(self.btnClicked_Ping)
        self.ui.pushButton_Ping2.clicked.connect(self.btnClicked_Ping2)
        self.ui.pushButton_clear.clicked.connect(self.btnClicked_clear)
        self.running=False
        self.r=0
        self.SERVER_LOST=0



    def btnClicked_PPPoE_th(self):
        print('Press buton PPPoE th')
        self.thread = QThread(self)
        self.worker = Worker()
        self.worker.moveToThread(self.thread)
 
        self.thread.started.connect(self.worker.process)
        self.worker.finished.connect(self.thread.quit)
        self.worker.finished.connect(self.worker.deleteLater)
        self.thread.finished.connect(self.thread.deleteLater)
        self.worker.message.connect(self.text)
        self.thread.start()

    def btnClicked_Speedtest(self):
        print('Press buton Speedtest')
        self.output = check.check_speedtest()
        if self.output != 0:
            self.ui.plainTextEdit.appendPlainText(self.output)
            application.running=False
            return
        if  self.ui.checkBox.isChecked(): self.ui.plainTextEdit.clear()
        self.servers=[]
        if self.ui.checkBox_2.isChecked(): self.servers.append(17014)
        if self.ui.checkBox_3.isChecked(): self.servers.append(1907)
        if self.ui.checkBox_4.isChecked(): self.servers.append(4503)
        if self.ui.checkBox_5.isChecked(): self.servers.append(2703)
        if self.ui.checkBox_6.isChecked(): self.servers.append(25286)
        if len(self.servers) == 0: self.servers=[17014]
        self.i=0
        for self.server in self.servers:
            self.server=[self.server]
            self.t=str(datetime.datetime.now())
            self.d, self.u, self.p, self.n ,self.s = speed.speed(self.server)
            self.l=[]
            self.i += 1
            self.l.append('Test №{}'.format(self.i)+' '+self.n+' '+self.s)
            self.l.append(self.t)
            self.l.append('Download: {:.2f} Mb/s'.format(self.d / 1024 / 1024))
            self.l.append('Upload: {:.2f} Mb/s'.format(self.u / 1024 / 1024))
            self.l.append('Ping: {} ms'.format(self.p))
            self.t=str(datetime.datetime.now())
            self.l.append(self.t)
            self.l.append('#'*80)
            self.output='\n'.join(self.l)
            if self.d == 0 and self.u == 0 and self.p == 0 and self.n == "name" and self.s == "sponsor":
                self.output='No connect internet!!!'
            print(self.output)
            self.ui.plainTextEdit.appendPlainText(self.output)
            
    def btnClicked_Ping(self):
        print('Press buton Ping')
        if  self.ui.checkBox.isChecked(): self.ui.plainTextEdit.clear()
        self.servers=[]
        if self.ui.checkBox_mailnchelny.isChecked(): self.servers.append('mail.n-chelny.ru')
        if self.ui.checkBox_google.isChecked(): self.servers.append('google.com')
        if self.ui.checkBox_ya.isChecked(): self.servers.append('ya.ru')
        if self.ui.checkBox_vk.isChecked(): self.servers.append('vk.com')
        if self.ui.checkBox_github.isChecked(): self.servers.append('github.com')
        if self.ui.checkBox_pornhub.isChecked(): self.servers.append('pornhub.com')
        if self.ui.checkBox_googleip.isChecked(): self.servers.append('8.8.8.8')
        if self.ui.checkBox_python.isChecked(): self.servers.append('python.org')
        if len(self.servers) == 0: self.servers=['mail.n-chelny.ru']
        self.i=0
        for self.server in self.servers:
            self.i += 1
            self.t=str(datetime.datetime.now())
            self.o = icmp.ping_fun(type_='slow',address=self.server)
            self.output = str(self.o)
            print(self.output)
            
            self.ui.plainTextEdit.appendPlainText('Ping test №{}'.format(self.i)+' '+self.server)
            self.ui.plainTextEdit.appendPlainText(self.t)
            self.ui.plainTextEdit.appendPlainText(self.output)
            self.ui.plainTextEdit.appendPlainText('#'*80)
            
    def btnClicked_Ping2(self):
        print('Press buton Ping2')
        if  self.ui.checkBox.isChecked(): self.ui.plainTextEdit.clear()
        self.servers=[]
        if self.ui.checkBox_mailnchelny.isChecked(): self.servers.append('mail.n-chelny.ru')
        if self.ui.checkBox_google.isChecked(): self.servers.append('google.com')
        if self.ui.checkBox_ya.isChecked(): self.servers.append('ya.ru')
        if self.ui.checkBox_vk.isChecked(): self.servers.append('vk.com')
        if self.ui.checkBox_github.isChecked(): self.servers.append('github.com')
        if self.ui.checkBox_pornhub.isChecked(): self.servers.append('pornhub.com')
        if self.ui.checkBox_googleip.isChecked(): self.servers.append('8.8.8.8')
        if self.ui.checkBox_python.isChecked(): self.servers.append('python.org')
        if len(self.servers) == 0: self.servers=['mail.n-chelny.ru']
        self.i=0
        for self.server in self.servers:
            self.i += 1
            self.t=str(datetime.datetime.now())
            self.o = icmp.ping_fun(type_='fast',address=self.server)
            self.output = str(self.o)
            print(self.output)
            
            self.ui.plainTextEdit.appendPlainText('Ping test №{}'.format(self.i)+' '+self.server)
            self.ui.plainTextEdit.appendPlainText(self.t)
            self.ui.plainTextEdit.appendPlainText(self.output)
            self.ui.plainTextEdit.appendPlainText('#'*80)

    def text(self, i, p=0):
        if p == 0:
            self.ui.plainTextEdit.appendPlainText(str(i))
            self.ui.plainTextEdit.ensureCursorVisible()
        if p == 1: self.ui.lineEdit.setText(str(i))
        if p == 2: self.ui.lineEdit_2.setText(str(i))


    def btnClicked_clear(self):
        print('Press buton clear')
        self.ui.plainTextEdit.clear()
        self.r=0
        self.SERVER_LOST=0
  


app = QApplication([])
application = mywindow()
application.show()
#app.exec_()
sys.exit(app.exec())