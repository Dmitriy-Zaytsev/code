#НЕ СКРИПТ ПРИМЕР
#ЗНАК - в diff означает сравнить не файл а stdin c 2.txt
dima@0405wscre313b2:~$ cat 1.txt
1
2222
3
4
5
6
7
8
9
10


dima@0405wscre313b2:~$ cat 1.txt | grep 1 
1
10


dima@0405wscre313b2:~$ cat 1.txt | grep 1 | diff - 2.txt -y
1                                                               1
                                                              > 22
                                                              > 3
                                                              > 4
                                                              > 5
                                                              > 6
                                                              > 7
                                                              > 8
                                                              > 9
10                                                              10

