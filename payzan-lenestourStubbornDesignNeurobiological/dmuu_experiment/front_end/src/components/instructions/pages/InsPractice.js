import React, { Component } from 'react';
import {Row, Container} from 'react-bootstrap';
import { Link } from 'react-router-dom';
import { connect } from 'react-redux';
import templateParser from '../../../utility/TemplateParser';

const TEXT_FILE = "practice.json";

class InsPractice extends Component {

    constructor(props)
    {
        super(props);

        const { title, para1, para2 } = this.props.text;

        const { missed_trials } = this.props.config.params;
        this.state = {
            title,
            para1,
            para2: templateParser(para2, {missed_trials})
        }
    }

    render() {

        const { title, para1, para2 } = this.state;

        return (
            <div>
                <Row className="mt-5 justify-content-center text-center">
                    <h1>{title}</h1>
                </Row>
                <Container className="mt-5">
                    <Row>
                        <p>{para1}</p>
                    </Row>
                    <Row className="mt-5">
                        <p dangerouslySetInnerHTML={{__html: para2}}></p>
                    </Row>
                    <Row className="mt-5 justify-content-center">
                        <Link to="/game/practice" className="btn btn-primary">START PRACTICE</Link>
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

export default connect(mapStateToProps)(InsPractice);