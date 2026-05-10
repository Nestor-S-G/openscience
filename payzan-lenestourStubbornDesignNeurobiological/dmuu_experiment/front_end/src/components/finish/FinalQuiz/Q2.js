import React, { Component } from 'react'
import { Form, Button, Card } from 'react-bootstrap';


export default class Q2 extends Component {

    state = {
        selected: false
    }

    onChange = (e) => {
        this.props.onChange(e);
        this.setState({selected: true});
    }

    render() {
        return (
            <Card data-test-id="cy-FinalQuiz-Q2-box">
                <Card.Header as="h5">Do you remember having asked Aaron to press the lever in some of the rounds during the {this.props.color} sessions?</Card.Header>
                <Card.Body>
                    <Form key="q2" onSubmit={this.props.onSubmit}>
                        <Form.Group onChange={this.onChange}>
                            <Form.Check 
                                data-test-id="cy-FinalQuiz-Q2-yes"
                                type="radio" 
                                name="q2" 
                                label="yes"
                                value="a"
                            />
                            <Form.Check 
                                data-test-id="cy-FinalQuiz-Q2-no"
                                type="radio" 
                                name="q2"  
                                label="no"
                                value="b"
                            />
                        </Form.Group>
                        <Button
                            data-test-id="cy-FinalQuiz-Q2-submit"
                            type="submit" 
                            disabled={!this.state.selected}
                        >
                            Submit
                        </Button>
                    </Form>
                </Card.Body>
            </Card>
        )
    }
}
