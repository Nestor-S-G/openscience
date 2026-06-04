import React, { Component } from 'react'
import { Form, Button, Card } from 'react-bootstrap';

export default class Q1 extends Component {

    state = {
        selected: false
    }

    onChange = (e) => {
        this.props.onChange(e);
        this.setState({selected: true});
    }

    render() {
        return (
            <Card data-test-id="cy-FinalQuiz-Q1-box">
                <Card.Header as="h5">What did a {this.props.color} background indicate?</Card.Header>
                <Card.Body>
                    <Form onSubmit={this.props.onSubmit}>
                        <Form.Group onChange={this.onChange}>
                            <Form.Check 
                                data-test-id="cy-FinalQuiz-Q1-toughsession"
                                type="radio" 
                                name="q1" 
                                value="a"
                                label="A tough session, greater chance to lose."
                            />
                            <Form.Check
                                data-test-id="cy-FinalQuiz-Q1-goodsession"
                                type="radio" 
                                name="q1" 
                                value="b"
                                label="A good session, greater chance to win."
                            />
                            <Form.Check 
                                data-test-id="cy-FinalQuiz-Q1-dontknow"
                                type="radio" 
                                name="q1" 
                                value="c" 
                                label="I don't know."
                            />
                        </Form.Group>
                        <Button
                            data-test-id="cy-FinalQuiz-Q1-submit" 
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
