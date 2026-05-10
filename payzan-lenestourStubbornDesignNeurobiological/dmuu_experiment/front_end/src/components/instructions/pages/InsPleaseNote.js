import React, { Component } from 'react';
import {Row, Container} from 'react-bootstrap';
import { connect } from 'react-redux';

const TEXT_FILE = "please_note.json";

class InsPleaseNote extends Component {

    render() {

        const { title, para1 } = this.props.text;

        return (
            <div>
                <Row className="mt-5 justify-content-center">
                    <h1>{title}</h1>
                </Row>
                <Container className="mt-5">
                    <p>{para1}</p>
                </Container>
            </div>
        )
    }
}

// Redux
const mapStateToProps = (state) => {
    return {
        text: state.instruction.text[TEXT_FILE]
    }
}

export default connect(mapStateToProps)(InsPleaseNote);