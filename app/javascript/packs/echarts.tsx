import * as React from 'react';

import * as Echarts from 'echarts';

// @types/echarts 里面这个函数的签名有误，做个修补
declare module "echarts" {
    export function getInstanceByDom(target: HTMLDivElement | HTMLCanvasElement): Echarts.ECharts;
}

interface ReactEchartsProps {
    id: string; // dom id
    option: Echarts.EChartOption;   // echarts的option
    showLoading: boolean;   // 是否显示loading动画
    style: any; // 内联样式
}

export default class ReactEcharts extends React.Component<ReactEchartsProps, any> {

    componentDidMount() {
        this.updateEcharts();
        return;
    }

    render() {
        return (
            <div id={this.props.id} style={this.props.style}/>
        )
    }

    componentDidUpdate() {
        this.updateEcharts();
        return;
    }

    private getEchartsInstance(): Echarts.ECharts {
        const dom: HTMLDivElement = document.getElementById(this.props.id) as HTMLDivElement;
        return Echarts.getInstanceByDom(dom) as Echarts.ECharts || Echarts.init(dom);
    }

    private updateEcharts() {
        const echartsInstance: Echarts.ECharts = this.getEchartsInstance();
        if (this.props.showLoading) {
            echartsInstance.showLoading();
        } else {
            echartsInstance.hideLoading();
            if (this.props.option) {
                echartsInstance.setOption(this.props.option);
            }
        }
        return;
    }
}