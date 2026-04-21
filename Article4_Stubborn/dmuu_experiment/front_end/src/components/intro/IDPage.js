import React, { Component } from "react";
import { Button, Card, Container, Form, Row } from "react-bootstrap";
import { Redirect } from "react-router-dom";
import { connect } from "react-redux";
import {
    setPersonalInfoFirstName,
    setPersonalInfoLastName,
} from "../../redux/playerStats/playerStatsActions";

class IDPage extends Component {
    state = {
        name: "",
        surname: "",
        invalidName: false,
        invalidSurname: false,
        valid: false,
    };

    onSubmit = () => {
        const { name, surname } = this.state;
        let valid = false;

        let invalidName = name === "";

        let invalidSurname = surname === "";

        if (!invalidName && !invalidSurname) {
            valid = true;
        }
        this.setState({
            invalidName,
            invalidSurname,
            valid,
        });
    };

    onChange = (e) => {
        this.setState({ [e.target.id]: e.target.value });
    };

    render() {
        if (this.state.valid) {
            const { name, surname } = this.state;

            this.props.saveFirstName(name);
            this.props.saveLastName(surname);

            return <Redirect to="/demographic" />;
        }

        return (
            <Container className="mt-5">
                <Card>
                    <Card.Header as="h4">Please enter your details</Card.Header>
                    <Card.Body>
                        <Form>
                            <Form.Group>
                                <Form.Label>Name</Form.Label>
                                <Form.Control
                                    type="text"
                                    id="name"
                                    onChange={this.onChange}
                                    value={this.state.name}
                                />
                                <Form.Text>
                                    {this.state.invalidName && (
                                        <p style={{ color: "red" }}>
                                            Please enter your name
                                        </p>
                                    )}
                                </Form.Text>
                            </Form.Group>
                            <Form.Group>
                                <Form.Label>Last Name</Form.Label>
                                <Form.Control
                                    type="text"
                                    id="surname"
                                    onChange={this.onChange}
                                    value={this.state.surname}
                                />
                                <Form.Text>
                                    {this.state.invalidSurname && (
                                        <p style={{ color: "red" }}>
                                            Please enter your surname
                                        </p>
                                    )}
                                </Form.Text>
                            </Form.Group>
                            <Form.Group>
                                <Form.Label>Email</Form.Label>
                                <Form.Control
                                    type="email"
                                    id="email"
                                    value={this.props.email}
                                    readOnly
                                />
                            </Form.Group>
                            <Button onClick={this.onSubmit}>Submit</Button>
                        </Form>
                    </Card.Body>
                </Card>
                <Row className="mt-5">
                    <h1>
                        Note during and after the game, please do not close the
                        browser, click the back button, or refresh, as if you do the
                        experiment will end!
                    </h1>
                </Row>
            </Container>
        );
    }
}

// Redux stuff
const mapStateToProps = (state) => {
    return {
        email: state.stats.personal_info.email,
    };
};

const mapDispatchToProps = (dispatch) => {
    return {
        saveFirstName: (first_name) =>
            dispatch(setPersonalInfoFirstName(first_name)),
        saveLastName: (last_name) =>
            dispatch(setPersonalInfoLastName(last_name)),
    };
};

export default connect(mapStateToProps, mapDispatchToProps)(IDPage);
