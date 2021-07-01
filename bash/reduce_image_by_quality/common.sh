#!/bin/bash
# --------------------------------------------------------
# - 概要：バッチ開始日時文字列の生成と、ログ用関数の定義。
# --------------------------------------------------------

# 日付変数
START_TIMESTAMP="$(date "+%Y%m%d%H%M%S")"
START_YMD_HMS="${START_TIMESTAMP:0:8}_${START_TIMESTAMP:8:6}"
START_YMD_HM="${START_TIMESTAMP:0:8}_${START_TIMESTAMP:8:4}"
START_YMD="${START_TIMESTAMP:0:8}"

# ログレベル
# デフォルトは全レベル出力。
# レベルを変更する場合は、このスクリプトを呼んだあとで、呼び出し側スクリプトでLOG_LEVELを上書きする。
LOG_LEVEL=0
LOG_LEVEL_TRACE=1
LOG_LEVEL_DEBUG=2
LOG_LEVEL_INFO=3
LOG_LEVEL_WARN=4
LOG_LEVEL_ERROR=5
LOG_LEVEL_NONE=6

# ログ出力関数
# $1=ログ文字列 $2=ログレベルを表す数値 $3=ログレベルを表す文字列 $4=呼出元ファイル $5=呼出元行番号
function log() {
    if [ "${LOG_LEVEL}" -le "$2" ]; then
        local TIMESTAMP="$(date "+%Y%m%d-%H%M%S")"
        local LOG="${TIMESTAMP} ($4:$5) [${3}] ${1}"
        echo -e "${LOG}"
    fi
}
function logError() {
    log "$1" "${LOG_LEVEL_ERROR}" "ERROR" "${BASH_SOURCE[1]##*/}" "${BASH_LINENO[0]}"
}
function logWarn() {
    log "$1" "${LOG_LEVEL_WARN}" "WARN" "${BASH_SOURCE[1]##*/}" "${BASH_LINENO[0]}"
}
function logInfo() {
    log "$1" "${LOG_LEVEL_INFO}" "INFO" "${BASH_SOURCE[1]##*/}" "${BASH_LINENO[0]}"
}
function logDebug() {
    log "$1" "${LOG_LEVEL_DEBUG}" "DEBUG" "${BASH_SOURCE[1]##*/}" "${BASH_LINENO[0]}"
}
function logTrace() {
    log "$1" "${LOG_LEVEL_TRACE}" "TRACE" "${BASH_SOURCE[1]##*/}" "${BASH_LINENO[0]}"
}
