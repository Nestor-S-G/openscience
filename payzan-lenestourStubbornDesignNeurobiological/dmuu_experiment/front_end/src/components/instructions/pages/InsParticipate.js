import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Row } from 'react-bootstrap';

const TEXT_FILE = 'participate.json';

class InsParticipate extends Component {
    render() {
        const { title } = this.props.text;
        return (
            <div className="d-flex flex-column">
                <Row className="justify-content-center pt-5 text-center">
                    <h1>{title}</h1>
                </Row>
                <ul>
                    {Object.keys(this.props.text).map((val, id) => {
                        return (val !== 'title') ?
                        (
                            <li key={id} className="justify-content-center mt-5">
                                <p>{this.props.text[val]}</p>
                            </li>
                        )
                        : null;
                    })}
                </ul>
            </div>
        )
    }
}

const mapStateToProps = (state) => {
    return {
        text: state.instruction.text[TEXT_FILE]
    }
}

export default connect(mapStateToProps)(InsParticipate);