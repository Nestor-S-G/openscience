import React, { Component } from "react";
import { Container, Form, Button } from "react-bootstrap";
import { connect } from "react-redux";
import { setDemographicInfo } from "../../redux/playerStats/playerStatsActions";

const MAJORS = {
    stem: "STEM (Science, Technology, Engineering, Medicine)",
    business: "Business",
    humanities: "Humanities",
    other: "Other",
};

const GENDER = {
    male: "Male",
    female: "Female",
    other: "Other",
};

class Demographic extends Component {
    state = {
        age: 0,
        gender: GENDER.female,
        major: MAJORS.stem,
    };

    submit = () => {
        let major;
        switch (this.state.major) {
            case MAJORS.stem:
                major = 1;
                break;

            case MAJORS.business:
                major = 2;
                break;

            case MAJORS.humanities:
                major = 3;
                break;

            default:
                major = 4;
                break;
        }

        const demographic = {
            age: parseInt(this.state.age),
            gender:
                this.state.gender === GENDER.female
                    ? 1
                    : this.state.gender === GENDER.male
                    ? 2
                    : 3,
            major,
        };
        this.props.saveDemographic(demographic);
        this.props.history.push("/chance");
    };

    render() {
        return (
            <Container className="mt-5">
                <Form>
                    <Form.Group>
                        <Form.Label>What is your age?</Form.Label>
                        <Form.Control
                            type="number"
                            value={this.state.age}
                            onChange={(e) =>
                                this.setState({ age: e.target.value })
                            }
                        />
                    </Form.Group>

                    <Form.Group>
                        <Form.Label>What is your gender?</Form.Label>
                        <Form.Control
                            as="select"
                            onChange={(e) =>
                                this.setState({ gender: e.target.value })
                            }
                            value={this.state.gender}
                        >
                            <option>{GENDER.female}</option>
                            <option>{GENDER.male}</option>
                            <option>{GENDER.other}</option>
                        </Form.Control>
                    </Form.Group>
                    <Form.Group>
                        <Form.Label>What is your area of study?</Form.Label>
                        <Form.Control
                            as="select"
                            onChange={(e) =>
                                this.setState({ major: e.target.value })
                            }
                            value={this.state.major}
                        >
                            <option>{MAJORS.stem}</option>
                            <option>{MAJORS.business}</option>
                            <option>{MAJORS.humanities}</option>
                            <option>{MAJORS.other}</option>
                        </Form.Control>
                    </Form.Group>

                    <Button onClick={this.submit}>Submit</Button>
                </Form>
            </Container>
        );
    }
}

const mapDispatchToProps = (dispatch) => {
    return {
        saveDemographic: (demographic) =>
            dispatch(setDemographicInfo(demographic)),
    };
};

export default connect(null, mapDispatchToProps)(Demographic);
