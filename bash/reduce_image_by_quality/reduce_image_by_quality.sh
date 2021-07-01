#!/bin/bash

function main() {

	# 対象ファイルリストファイルを読み込む
	logInfo "MAX_SIZE_BYTE=${MAX_SIZE_BYTE}"
	cat $FILELIST_FILE_PATH | while read line
	do
		logDebug '-------------------------------'
		logTrace "filename=${line}"
		handleOneFile $line
	done

}

function handleOneFile() {
	local readonly fileName=$1
	logDebug "filename=${fileName}"
	
	local readonly inputPath="${INPUT_DIR}/${fileName}"
	local readonly outputPath="${OUTPUT_DIR}/${fileName}"

	# ファイル存在確認
	if [ ! -e $inputPath ]; then
		logError "input file not exists: ${fileName}"
		return
	fi

	# インプットが最初から許容サイズ以下の場合はコピーして終わり
	local inputSize=$(getSize $inputPath)
	logTrace "inputSize=[${inputSize}]"
	if [ "$inputSize" -le "$MAX_SIZE_BYTE" ]; then
		logInfo "not need to compress: ${fileName}"
		cp -fp $inputPath $outputPath
		return
	fi
	
	local qMax=100 # jpgの最高画質
	local qMin=1   # jpgの最低画質
	local q=50     # テストする画質の初期値
	
	while :
	do
		magick $inputPath -quality $q $outputPath
		
		local outputSize=$(getSize $outputPath)
		logTrace "q=${q}, qMin=${qMin}, qMax=${qMax}, size=${outputSize}"

		# qMinとqMaxの差が1になったときの処理。
		if [ $(( qMax - qMin )) -eq 1 ]; then
			
			# シェルスクリプトの演算子 「/」は、小数以下切り捨てなので、必ずq=qMin。のはず。
			if [ "$q" -ne "$qMin" ]; then
				logError '想定外の判定、バグなので要修正'
				
				# 来ないはずだけど保険コード（動作未検証）
				# q=qMaxの場合は、qだとサイズオーバーなので、qMinで出力しなおす。
				if [ "$q" -eq "$qMax" ]; then
					q=$qMin
					magick $inputPath -quality $q $outputPath
				fi
			fi
			
			
			# 基準サイズ以下にできなかった場合は警告ログを出す
			outputSize=$(getSize $outputPath)
			if [ "$outputSize" -gt "$MAX_SIZE_BYTE" ]; then
				logWarn "最低品質でもサイズオーバーです。q=${q}, size: ${outputSize} file: ${fileName}"
			else
				logInfo "compress ok. q=${q}, size=${outputSize}, file=${fileName}"
			fi
			
			return
		fi

		# qをqMinかqMaxのどちらかに設定し、その中間をqとする
		if [ "$outputSize" -le "$MAX_SIZE_BYTE" ]; then
			# 指定サイズより小さくなった場合
			logTrace "q=${q} is size OK: $outputSize"
			qMin=$q
		else
			# 指定サイズよりも大きくなった場合
			logTrace "q=${q} is size NG: $outputSize"
			qMax=$q
		fi
		q=$(( (qMin + qMax) / 2 ))
		
	done
	
	
}

# ファイルサイズを取得
function getSize() {
	filePath=$1
	echo $(ls -la ${filePath} | cut -d ' ' -f 5)
}



# -------------------------
# 処理開始
# -------------------------

# 共通スクリプト読み込み
cd `dirname $0`
. ./common.sh
. ./reduce_image_by_quality_conf.sh

# ログ定義
# LOGFILE="${START_YMD_HMS}_fetch.log"
# LOG_LEVEL=${LOG_LEVEL_TRACE}
# LOGPATH="$(cd $(dirname $0); pwd)/log/${LOGFILE}"
# exec 1> >(tee -a "${LOGPATH}") 2>&1

logDebug "========================"
logInfo "start."

# メイン実行
main

