import React, { Component } from 'react';
import {Row, Container, Col, Image} from 'react-bootstrap';
import { connect } from 'react-redux';
import templateParser from '../../../utility/TemplateParser';

const TEXT_FILE = "cheeky.json";

class InsCheeky extends Component {

    constructor(props)
    {
        super(props);

        const { title, para1, para2, para3 } = this.props.text;

        const {bet_amount} = this.props.config.params;
        this.state = {
            title, 
            para1: templateParser(para1, {bet_amount}), 
            para2,
            para3
        }
    }

    render() {

        let pub = process.env.PUBLIC_URL;
        const { title, para1, para2, para3 } = this.state;

        return (
            <div>
                <Row className="mt-5 justify-content-center">
                    <h1>{title}</h1>
                </Row>
                <Container className="mt-5">
                    <Row>
                        <p>{para1}</p>
                    </Row>
                    <Row>
                        <p>{para2}</p>
                    </Row>
                    <Row className="justify-content-center">
                        <p>{para3}</p>
                    </Row>
                    <Row className="pt-3 justify-content-center">
                        <Col>
                            <Row className="justify-content-center">
                                <h3>Normal Aaron</h3>
                            </Row>
                            <Row className="justify-content-center">
                                <Image src={pub + "/assets/aaron_reveal_win.png"}/>
                            </Row>
                        </Col>
                        <Col>
                            <Row className="justify-content-center">
                                <h3>Cheeky Aaron</h3>
                            </Row>
                            <Row className="justify-content-center">
                                <Image src={pub + "/assets/aaron_cheeky_reveal_win.png"}/>
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

export default connect(mapStateToProps)(InsCheeky);