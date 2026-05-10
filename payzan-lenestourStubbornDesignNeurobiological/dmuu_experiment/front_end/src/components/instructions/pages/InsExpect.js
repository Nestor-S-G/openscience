import React, { Component } from "react";
import { Row, Container, Image } from "react-bootstrap";
import { connect } from "react-redux";
import templateParser from "../../../utility/TemplateParser";

const TEXT_FILE = "expect.json";

class InsExpect extends Component {
    constructor(props) {
        super(props);

        const { para1 } = this.props.text;

        const { color, reward } = this.props.config.params;
        const { low_name, high_name } = color;
        const { low, high } = reward;

        this.state = {
            para1: templateParser(para1, {
                low_color: low_name,
                high_color: high_name,
                low_amount: low,
                high_amount: high,
            }),
        };
    }

    render() {
        let pub = process.env.PUBLIC_URL;
        const { para1 } = this.state;

        return (
            <>
                <Container className="mt-5">
                    <Row className="justfiy-content-center">
                        <p>{para1}</p>
                    </Row>
                    <Row className="mt-3 justify-content-center">
                        <Image src={pub + "/assets/instruction_pages/incoming.png"}/>
                    </Row>
                </Container>
            </>
        );
    }
}

// Redux
const mapStateToProps = (state) => {
    return {
        config: state.config.config,
        text: state.instruction.text[TEXT_FILE],
    };
};

export default connect(mapStateToProps)(InsExpect);
