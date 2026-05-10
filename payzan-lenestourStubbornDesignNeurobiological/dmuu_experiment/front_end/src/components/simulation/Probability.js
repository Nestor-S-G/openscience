import React, { Component } from "react";
import { Card, Row } from "react-bootstrap";
import { Chart } from "react-google-charts";
import invert from "invert-color";

export default class Probability extends Component {
    state = {
        wins: 0,
        loses: 0,
        count: 0,
        data: [
            ["Type", "Amount"],
            ["Win", 0],
            ["Lose", 0],
        ],
        win: true,
        ready: false,
    };

    startAnim = () => {
        if (!this.state.ready) {
            this.setState({ ...this.state, ready: true });
            this.timer = setInterval(() => this.tick(), 100);
        }
    };

    componentWillUnmount() {
        clearInterval(this.timer);
    }

    resetSim = () => {
        this.setState({
            ...this.state,
            wins: 0,
            loses: 0,
            count: 0,
            ready: false,
        });
        clearInterval(this.timer);
        this.startAnim();
    };

    componentDidUpdate() {
        if (this.props.reset === true) {
            this.resetSim();
            this.props.resetFinish();
        }
    }

    tick() {
        this.draw();
    }

    draw = () => {
        let { wins, loses, count, win } = this.state;

        const pick = Math.random();
        if (pick * 100 <= this.props.prob) {
            wins += 1;
            win = true;
        } else {
            loses += 1;
            win = false;
        }

        count += 1;

        const data = [
            ["Type", "Amount"],
            ["Win", wins],
            ["Lose", loses],
        ];

        this.setState({ ...this.state, wins, loses, data, count, win });

        if (count >= this.props.draws) {
            // Finish draws
            clearInterval(this.timer);
            this.props.finish();
        }
    };

    render() {
        const { color } = this.props;
        const textColor = invert(color, true);

        return (
            <Card>
                <Card.Header
                    style={{ backgroundColor: color, color: textColor }}
                >
                    <h5>
                        Playing with winning probability {this.props.prob}% -
                        Round: {this.state.count}
                    </h5>
                </Card.Header>
                <Card.Body>
                    <Row className="justify-content-center">
                        Example {this.props.no}
                    </Row>
                    <Row className="justify-content-center text-center">
                        Playing with winning probability of{" "}
                        {this.props.prob}% means that on average, the ratio of
                        wins to losses is close to {this.props.prob / 100}
                    </Row>
                    <Row className="justify-content-center">
                        Win: {this.state.wins} Lose: {this.state.loses} Ratio:{" "}
                        {(this.state.wins / (this.state.count + 1)).toFixed(2)}
                    </Row>
                    <Row>
                        <div
                            style={{
                                flex: true,
                                minHeight: 400,
                                minWidth: 500,
                            }}
                        >
                            <Chart
                                width={"100%"}
                                height={"100%"}
                                chartType="ColumnChart"
                                data={this.state.data}
                                options={{
                                    hAxis: {
                                        title: "",
                                        minValue: 0,
                                        maxValue: 100,
                                    },
                                    vAxis: {
                                        title: "How Many Rounds",
                                        viewWindow: {
                                            max: 100,
                                            min: 0,
                                        },
                                    },
                                    colors: [this.props.color],
                                    animation: {
                                        duration: 100,
                                        easing: "linear",
                                        startup: "false",
                                    },
                                    legend: { position: "none" },
                                }}
                                chartEvents={[
                                    {
                                        eventName: "ready",
                                        callback: this.startAnim,
                                    },
                                ]}
                            />
                        </div>
                    </Row>
                </Card.Body>
            </Card>
        );
    }
}
