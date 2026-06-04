// Ask the player percentage chance the spinning results in matching slots i.e. winning probability
import React, { Component } from "react";
import { connect } from "react-redux";
import { Container, Form, Button, Row } from "react-bootstrap";
import { setChanceGuess } from "../../redux/playerStats/playerStatsActions";
import "./Chance.css";

export const CHANCE_CODING = {
    LESS_THAN_10: 0,
    BETWEEN_10_AND_30: 1,
    ABOVE_30: 2,
    NOT_SURE: 3,
};

const possible_answers = {
    LESS_THAN_10: { val: "lt10", string: "<10%" },
    BETWEEN_10_AND_30: { val: "btwn10n30", string: "Between 10% and 30%" },
    ABOVE_30: { val: "abv30", string: "Above 30%" },
    NOT_SURE: { val: "ntsure", string: "I'm not quite sure" },
};

const CHANCE_FORM_NAME = "chance";

class Chance extends Component {
    state = {
        chance: null,
    };

    onChange = (e) => {
        const { value } = e.target;
        let newValue = this.state.chance;

        if (value === possible_answers.LESS_THAN_10.val) {
            newValue = CHANCE_CODING.LESS_THAN_10;
        } else if (value === possible_answers.BETWEEN_10_AND_30.val) {
            newValue = CHANCE_CODING.BETWEEN_10_AND_30;
        } else if (value === possible_answers.ABOVE_30.val) {
            newValue = CHANCE_CODING.ABOVE_30;
        } else if (value === possible_answers.NOT_SURE.val) {
            newValue = CHANCE_CODING.NOT_SURE;
        }

        this.setState({ chance: newValue });
    };

    onSubmit = (e) => {
        const { chance } = this.state;

        e.preventDefault();
        if (chance !== null) {
            this.props.rdxSetChanceGuess(chance);
            this.props.history.push("/pregame");
        }
    };

    radioBox = (obj) => {
        return (
            <Form.Check
                type="radio"
                className="chance-form-check"
            >
                <input
                    type="radio"
                    name={CHANCE_FORM_NAME}
                    value={obj.val}
                    className="chance-radio-butt"
                />
                <Form.Check.Label>
                    <h2>{obj.string}</h2>
                </Form.Check.Label>
            </Form.Check>
        );
    };

    render() {
        const { chance } = this.state;

        return (
            <Container className="h-100 d-flex flex-column">
                <Row className="mt-5 justify-content-center text-center">
                    <h1 style={{ lineHeight: "200%" }}>
                        What is the chance that the spinning stops with the shapes being the same
                        (i.e., it's a winning spin) in a yellow session?
                    </h1>
                </Row>
                <Row className="flex-fill" />
                <Row className="justify-content-center">
                    <Form onSubmit={this.onSubmit}>
                        <Form.Group onChange={this.onChange}>
                            {this.radioBox(possible_answers.LESS_THAN_10)}
                            {this.radioBox(possible_answers.BETWEEN_10_AND_30)}
                            {this.radioBox(possible_answers.ABOVE_30)}
                            {this.radioBox(possible_answers.NOT_SURE)}
                        </Form.Group>
                        <Row className="justify-content-center mt-5 mb-5">
                            <Button
                                type="submit"
                                disabled={chance == null}
                            >
                                Submit
                            </Button>
                        </Row>
                    </Form>
                </Row>
                <Row className="flex-fill" />
            </Container>
        );
    }
}

// Redux stuff
const mapDispatchToProps = (dispatch) => {
    return {
        rdxSetChanceGuess: (chance_guess) =>
            dispatch(setChanceGuess(chance_guess)),
    };
};

export default connect(null, mapDispatchToProps)(Chance);