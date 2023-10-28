DATE=$(shell date '+%Y-%m-%d-%H%M')


# 自身の環境に合わせる
APP_HOME:=$(HOME)/isucon/isucon10-qualify

DB_SLOW_LOG:=${APP_HOME}/webapp/logs/mysql/mysql-slow.log
ROTATED_LOG_DIR:=${APP_HOME}/webapp/logs/mysql/rotated

NGINX_ACCESS_LOG:=${APP_HOME}/webapp/logs/nginx/access.log


all: bench slow-query log-rotate

# benchを実行
.PHONY: bench
bench:
	cd $(APP_HOME)/bench && ./bench


# slow-queryを解析し、テキストファイルに出力
.PHONY: slow-query
slow-query:
	mkdir -p $(APP_HOME)/webapp/logs/mysql/slow-query-logs
	mysqldumpslow -s c -t 10 $(DB_SLOW_LOG) | tee $(APP_HOME)/webapp/logs/mysql/slow-query-logs/mysql-slow-$(DATE).log


# ログのローテーション
.PHONY: log-rotate
log-rotate:
	mkdir -p $(ROTATED_LOG_DIR)
	mv $(DB_SLOW_LOG) $(ROTATED_LOG_DIR)/mysql-slow-$(DATE).log
	touch $(DB_SLOW_LOG)
