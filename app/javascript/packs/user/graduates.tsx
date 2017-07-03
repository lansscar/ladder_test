/**
 * Created by songlian on 21/05/2017.
 */

/// <reference path="../../types/dingding.d.ts" />

import * as React from "react";
import * as ReactDOM from "react-dom";

import 'whatwg-fetch';

import {style} from 'typestyle';
import {percent} from 'csx';

import * as Echarts from 'echarts';
import ReactEcharts from '../echarts';

import * as FontAwesome from 'react-fontawesome';

interface EchartsProps {
    id: string;     // dom id
    echartsID: string;  // echarts dom id
}

interface EchartsState {
    height: number | string;    // object高
    echartsOption: Echarts.EChartOption;    // echarts的配置
    showLoading: boolean;   // 是否显示loading动画
    data?: Array<ScoreData>;    // 服务器返回的数据
}

// 返回的数据类型
interface ScoreData {
    name: string;   // 姓名
    score: number;  // 分数
    color: string;  // 显示的颜色
}

// echarts component
class EchartsComponent extends React.Component<EchartsProps, EchartsState> {

    private echartsOriginalHeight: number;    // echarts的原始高度，也就是第一次渲染完毕后的高度

    constructor() {
        super();
        this.state = {
            height: "100vh",
            echartsOption: null,
            showLoading: false
        };
        this.echartsOriginalHeight = 0;
    }

    componentDidMount() {
        // 记录第一次渲染完毕后的echarts节点高度
        if (0 == this.echartsOriginalHeight) {
            this.echartsOriginalHeight = document.getElementById(this.props.echartsID).clientHeight;
        }

        this.request();
    }

    render() {
        const componetStyle: string = style({width: percent(100)});
        const refreshStyle: string = style({
            borderRadius: '100%',
            top: '5px',
            color: '#828282',
            cursor: 'pointer',
            display: 'none',
            position: 'fixed',
            right: '5px',
            textAlign: 'center',
            transition: 'all 0.2s ease-in-out 0s',
            zIndex: 1005
        });
        return (
            <div id={this.props.id} className={componetStyle}>
                <ReactEcharts id={this.props.echartsID} style={{height: this.state.height}}
                              option={this.state.echartsOption} showLoading={this.state.showLoading}/>
                <FontAwesome name="refresh" size="5x" className={refreshStyle} onClick={this.request.bind(this)}/>
            </div>
        )
    }

    // 请求数据
    request() {
        if (this.state.showLoading) {
            // 正在显示loading界面，说明正在请求数据，不响应再次请求
            return;
        }

        this.setState({
            echartsOption: null,
            showLoading: true
        });

        const echartsComponet: EchartsComponent = this;
        fetch('/group/graduates/scores')
            .then(function (response) {
                if (!response.ok) {
                    throw Error(response.statusText);
                }
                return response;
            })
            .then(function (response) {
                response.json().then(function (data: Array<ScoreData>) {
                    echartsComponet.updateEcharts(data);
                    return;
                });
            })
            .catch(function (error) {
                dd.device.notification.toast({
                    text: "获取天梯数据失败：" + error.message
                });
                echartsComponet.setState({
                    showLoading: false
                });
            });
    }

    // 根据返回数据的数目来决定echarts的高度
    private calcChartHeightByDataLength(dataLength: number): number {
        return 20 * dataLength > this.echartsOriginalHeight ? 20 * dataLength : this.echartsOriginalHeight;
    }

    private updateEcharts(data: Array<ScoreData>) {
        data = pretreatData(data);
        const option: Echarts.EChartOption = {
            title: {
                text: '天梯——实时量化绩效考核'
            },
            tooltip: {},
            yAxis: {
                data: data.map(hash => `${hash.name}`),
                type: 'category',
                axisLabel: {
                    show: false,
                    inside: true
                },
            },
            xAxis: {
                position: 'top',
                type: 'value',
                splitLine: {
                    show: false
                }
            },
            series: [{
                type: 'bar',
                data: data.map(hash => hash.score),
                label: {
                    normal: {
                        position: 'insideLeft',
                        show: true,
                        formatter: '{b}: {c}分',
                        textStyle: {
                            color: '#000000'
                        }
                    }
                },
                itemStyle: {
                    normal: {
                        color: (params => data.map((hash) => hash.color)[params.dataIndex])
                    }
                }
            }],
            grid: {
                containLabel: true
            }
        };
        const echartsHeight: number = this.calcChartHeightByDataLength(data.length);
        this.setState({
            data: data,
            height: echartsHeight,
            echartsOption: option,
            showLoading: false
        });
    }
}

ReactDOM.render(
    <EchartsComponent id="echartsParent" echartsID="echarts"/>,
    document.getElementById("root")
);

// 数据预处理
function pretreatData(data: Array<ScoreData>): Array<ScoreData> {
    data = sortByScore(data);
    return colorByScore(data);
}

// 根据分数排名
function sortByScore(data: Array<ScoreData>): Array<ScoreData> {
    return data.sort((left: ScoreData, right: ScoreData) => left.score - right.score);
}

// 根据分数来决定颜色
function colorByScore(data: Array<ScoreData>): Array<ScoreData> {
    for (let d of data) {
        if (d.score >= 90) {
            d.color = '#00FF00' // 优，绿色
        }
        else if (d.score < 60) {
            d.color = '#FF0000' // 差，红色
        }
        else {
            d.color = '#CFCFCF'
        }
    }
    return data;
}
