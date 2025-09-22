import pandas as pd
import warnings
warnings.filterwarnings('ignore')

sql = 'SELECT * FROM banks'

#1 через mysql-connector-python напрямую к БД
import mysql.connector
conn1 = mysql.connector.connect(
    host="localhost",
    database="bank",
    user="Sergey",
    password="85912020"
)
print(pd.read_sql_query(sql, conn1), '\n')
conn1.close()

#2 через pymysql напрямую к БД
import pymysql
conn2 = pymysql.connect(
    host='localhost',
    user='Sergey',
    password='85912020',
    db='bank'
)
print(pd.read_sql_query(sql, conn2), '\n')
conn2.close()


#3 через ODBC - это как API для подключения к БД через различные программы (Excel, PowerBI, Python и др.)
import pyodbc
conn3 = pyodbc.connect('DSN=MyMySQLConnection;UID=Sergey;PWD=85912020')
print(pd.read_sql_query(sql, conn3), '\n')
conn3.close()

#4 напрямую через PANDAS c предустановленным PyMySQL - чистый python-клиент для MySQL
print(pd.read_sql_query(sql, con="mysql+pymysql://Sergey:85912020@localhost/bank"), '\n')

#5 через SQL Alchemy c предустановленным PyMySQL
from sqlalchemy import create_engine, text

# с PyMySQL
engine = create_engine('mysql+pymysql://Sergey:85912020@localhost/bank')
print(pd.read_sql_query(sql, engine), '\n')
# c mysql-connector-python
engine = create_engine('mysql+mysqlconnector://Sergey:85912020@localhost/bank')
print(pd.read_sql_query(sql, engine), '\n')
