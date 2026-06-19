import React from 'react';
import { Form, Button, Card } from 'react-bootstrap';

export default function Q3({onChangeRadio, onChangeText, showOther, finishQuiz}) {
    return (
        <Card data-test-id="cy-FinalQuiz-Q3-box">
            <Card.Header as="h5">Could you tell us a bit more about your decision on those rounds? (multiple replies is ok)</Card.Header>
            <Card.Body>
                <Form.Check 
                    data-test-id="cy-FinalQuiz-Q3-moremoney"
                    type="checkbox" 
                    name="q3"
                    onChange={onChangeRadio}
                    id="a"
                    label="I wanted to win more money"
                />
                <Form.Check 
                    data-test-id="cy-FinalQuiz-Q3-sameshapes"
                    type="checkbox" 
                    name="q3"
                    onChange={onChangeRadio}
                    id="b" 
                    label="I guessed the shapes would be the same on that round"
                />
                <Form.Check 
                    data-test-id="cy-FinalQuiz-Q3-random"
                    type="checkbox" 
                    name="q3"
                    onChange={onChangeRadio}
                    id="c" 
                    label="I just replied randomly"
                />
                <Form.Check 
                    data-test-id="cy-FinalQuiz-Q3-other"
                    type="checkbox" 
                    name="q3" 
                    onChange={onChangeRadio}
                    id="d"
                    label="other"
                />
                {showOther && <Form.Check 
                    data-test-id="cy-FinalQuiz-Q3-othertext"
                    type="input" onChange={onChangeText}/>}
                <Button
                    data-test-id="cy-FinalQuiz-Q3-submit"
                    className="mt-3" 
                    onClick={finishQuiz}
                >
                    Submit
                </Button>
            </Card.Body>
        </Card>
    )
}
