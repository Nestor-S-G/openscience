import React, { Component } from "react";
import { Container, Row, Image } from "react-bootstrap";
import break_image from "./break_image.jpg";
import "./BreakSequence.css";

export default class BreakSequence extends Component {

    constructor(props) {
        super(props);
        const time = props.time ? props.time : 0;

        this.state = {
            time_left: time,
        };
    }

    componentDidMount() {
        this.update = setInterval(() => {
            if (this.state.time_left > 0)
                this.setState({time_left: this.state.time_left - 1});
        }, 1000);
    }

    componentWillUnmount() {
        clearInterval(this.update);
    }

    render() {
        return (
            <Container className="h-100">
                <div className="d-flex flex-column justify-content-center h-100">
                    <Row className="justify-content-center text-center pt-5">
                        <h1>
                            Please focus on this image and just relax, the next
                            session is going to start soon in {Math.round(this.state.time_left)} seconds.
                        </h1>
                    </Row>
                    <Row className="justify-content-center pt-5">
                        <Image src={break_image} className="breakImg" />
                    </Row>
                </div>
            </Container>
        );
    }
}
