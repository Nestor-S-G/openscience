import React, { Component } from 'react';
import {Row, Container, Col, Image} from 'react-bootstrap';
import { connect } from 'react-redux';
import templateParser from '../../../utility/TemplateParser';

const TEXT_FILE = "rules.json";
const DIFFERENCE = 3;
const ROUNDS = 20;

class InsRules extends Component {

    constructor(props)
    {
        super(props);

        const { title, para1, para2, para3} = this.props.text;
        const {trials, repetitions, multiplier} = this.props.config.params;
        this.state = {
            title, 
            para1: templateParser(para1, {trials: ROUNDS*trials*repetitions, multiplier}),
            para2: templateParser(para2, {multiplier, amount_won: multiplier*DIFFERENCE}),
            para3
        };
    }

    render() {
        
        const { title, para1, para2, para3 } = this.state;

        return (
            <div>
                <Row className="pt-5 justify-content-center">
                    <h1>{title}</h1>
                </Row>
                <Container className="pt-5">
                    <Row>
                        <Col className="d-flex align-items-center justify-content-center">
                            <Image src={process.env.PUBLIC_URL + "/assets/coin_stack.png"}/>
                        </Col>
                        <Col>
                            <Row>
                                <p>{para1}</p>
                            </Row>
                            <Row>
                                <p>{para2}</p>
                            </Row>
                            <Row>
                                <p>{para3}</p>
                            </Row>
                        </Col>
                    </Row>
                </Container>
            </div>
        )
    }
}

// Redux
const mapStateToProps = (state) => {
    return {
        config: state.config.config,
        text: state.instruction.text[TEXT_FILE]
    }
}

export default connect(mapStateToProps)(InsRules);