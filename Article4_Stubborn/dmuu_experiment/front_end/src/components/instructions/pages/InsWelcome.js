import React, { Component } from "react";
import { Row, Col, Image as ImageBS, Container } from "react-bootstrap";
import { connect } from "react-redux";
import templateParser from "../../../utility/TemplateParser";
import Loader from "../../loader/Loader";

const TEXT_FILE = "welcome.json";

const FILE_PATH = process.env.PUBLIC_URL + "/assets/instruction_pages/";

const imgs = {
    aaron_wave: "aaron_wave.png",
    aaron_slot: "aaron_slot.png",
};

class InsWelcome extends Component {
    constructor(props) {
        super(props);
        const { title, para1, para2, para3 } = this.props.text;

        const { reward, bet_amount } = this.props.config.params;
        const { low, high } = reward;

        this.state = {
            title,
            para1,
            para2: templateParser(para2, { money_low: low, money_high: high }),
            para3: templateParser(para3, { bet_amount }),
            images: {},
            imagesLoaded: false,
        };
    }

    componentDidMount() {
        this.loadImages();
    }

    loadImages = () => {
        const keys = Object.keys(imgs).map((key) => key);
        const imageList = keys.map((key) => {
            return new Promise((resolve, reject) => {
                const img = new Image();
                img.src = FILE_PATH + imgs[key];
                img.onload = resolve(img);
                img.onerror = reject();
            });
        });
        Promise.all(imageList).then((vals) => {
            let images = {};
            for (let i = 0; i < keys.length; ++i) {
                images[keys[i]] = vals[i];
            }
            this.setState({ images, imagesLoaded: true });
        });
    };

    render() {
        const {
            title,
            para1,
            para2,
            para3,
            images,
            imagesLoaded,
        } = this.state;

        if (!imagesLoaded) return <Loader />;

        return (
            <div className="d-flex flex-column">
                <Row className="justify-content-center pt-5">
                    <h1>{title}</h1>
                </Row>
                <Container className="pt-5">
                    <Row>
                        <Col>
                            <Row className="justify-content-center">
                                <ImageBS
                                    src={images.aaron_wave.src}
                                    roundedCircle
                                />
                            </Row>
                            <Row className="justify-content-center mt-4">
                                <ImageBS
                                    src={images.aaron_slot.src}
                                />
                            </Row>
                        </Col>
                        <Col>
                            <Row>
                                <p>{para1}</p>
                                <p>{para2}</p>
                                <p>{para3}</p>
                            </Row>
                        </Col>
                    </Row>
                </Container>
            </div>
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

export default connect(mapStateToProps)(InsWelcome);
