all: stochastics.ex5

stochastics.ex5: stochastics.mq5
	-metaeditor64 /compile:stochastics.mq5 /log:log.log
	cat log.log
	rm log.log
