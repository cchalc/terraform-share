# Databricks notebook source
# MAGIC %sql CREATE DATABASE ${db_name} LOCATION 's3a://${bucket}/${db_name}.db'

# COMMAND ----------
from pyspark.sql.functions import *
spark.range(10).withColumn("department", lit("${db_name}")).write.saveAsTable('${db_name}.sample')