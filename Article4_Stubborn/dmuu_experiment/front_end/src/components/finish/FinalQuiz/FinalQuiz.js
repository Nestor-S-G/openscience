import React, { Component } from "react";
import { connect } from "react-redux";
import Q1 from "./Q1";
import Q2 from "./Q2";
import Q3 from "./Q3";

const quizStates = {
    QUESTION_ONE: "QUESTION_ONE",
    QUESTION_TWO: "QUESTION_TWO",
    QUESTION_THREE: "QUESTION_THREE",
};

class FinalQuiz extends Component {
    state = {
        curState: quizStates.QUESTION_ONE,
        q1: null,
        q2: null,
        q3: {
            a: false,
            b: false,
            c: false,
            d: false,
            extra: null,
        },
    };

    finishQuiz = () => {
        let q3 = null;
        if (this.state.q3.a || this.state.q3.b || this.state.q3.c || this.state.q3.d) {
            q3 = "";
        }
        if (this.state.q3.a) {
            q3 += "1";
        }
        if (this.state.q3.b) {
            q3 += "2";
        }
        if (this.state.q3.c) {
            q3 += "3";
        }
        if (this.state.q3.d) {
            q3 += "4";
        }
        if (q3 !== null)
        {
            q3 = parseInt(q3);
        }

        let q2 = this.state.q2;
        if (q2 !== null) {
            q2 = q2 === "a" ? 1 : 2;
        }

        const output = {
            q1: this.state.q1 === "a" ? 1 : this.state.q1 === "b" ? 2 : 3,
            q2,
            q3,
            other: this.state.q3.extra,
            correct: this.state.q1 === "b" ? 1 : 0,
        }
        this.props.finish(output);
    };

    // Q1 Methods

    submitQ1 = (e) => {
        e.preventDefault();
        if (this.state.q1 === "b" && this.props.didBetInCBlock) {
            e.target.reset();
            this.setState({ q2: "a", curState: quizStates.QUESTION_TWO });
        } else {
            this.finishQuiz();
        }
    };

    q1Change = (e) => {
        this.setState({ q1: e.target.value });
    };

    // Q2 Methods

    submitQ2 = (e) => {
        e.preventDefault();
        if (this.state.q2 === "a") {
            e.target.reset();
            this.setState({ curState: quizStates.QUESTION_THREE });
        } else {
            this.finishQuiz();
        }
    };

    q2Change = (e) => {
        this.setState({ q2: e.target.value });
    };

    // Q3 Methods

    q3Change = (e) => {
        const { id } = e.target;
        this.setState({ q3: { ...this.state.q3, [id]: !this.state.q3[id] } });
    };

    q3TextChange = (e) => {
        this.setState({ q3: { ...this.state.q3, extra: e.target.value } });
    };

    // Render methods

    selectPage = () => {
        const { low_color, high_color } = this.props;
        switch (this.state.curState) {
            case quizStates.QUESTION_ONE:
                return (
                    <Q1
                        color={high_color}
                        onChange={this.q1Change}
                        onSubmit={this.submitQ1}
                    />
                );

            case quizStates.QUESTION_TWO:
                return (
                    <Q2
                        color={low_color}
                        onChange={this.q2Change}
                        onSubmit={this.submitQ2}
                    />
                );

            case quizStates.QUESTION_THREE:
                return (
                    <Q3
                        onChangeRadio={this.q3Change}
                        onChangeText={this.q3TextChange}
                        showOther={this.state.q3.d}
                        finishQuiz={this.finishQuiz}
                    />
                );

            default:
                return <span>Loading....</span>;
        }
    };

    render() {
        return this.selectPage();
    }
}

const mapStateToProps = (state) => {
    return {
        didBetInCBlock: state.stats.bet_in_c_block
    }
}

export default connect(mapStateToProps)(FinalQuiz);