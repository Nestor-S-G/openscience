import React, { Component } from 'react';
import {Row, Container} from 'react-bootstrap';
import { connect } from 'react-redux';
import Quiz from '../../intro/Quiz';

const TEXT_FILE = "mcq_text.json";

class InsMCQ extends Component {

    render() {
        const { title, para1 } = this.props.text;
        return (
            <div>
                <Row className="mt-5 justify-content-center text-center">
                    <h1>{title}</h1>
                </Row>
                <Container className="mt-5">
                    <Row>
                        <p>{para1}</p>
                    </Row>
                    <Row className="mt-5 justify-content-center">
                        <Quiz config={this.props.config}/>
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

export default connect(mapStateToProps)(InsMCQ);