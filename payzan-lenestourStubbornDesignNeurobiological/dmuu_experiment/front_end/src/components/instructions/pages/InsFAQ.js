import React, { Component } from "react";
import { Row } from "react-bootstrap";
import { BACKEND_API_FETCHPDF } from "../../../backend_interface/backend_url";

class InsFAQ extends Component {
    render() {
        return (
            <div>
                <Row className="mt-5 justify-content-center text-center">
                    <h1>FAQs</h1>
                </Row>
                <Row>
                    <iframe 
                        title="pdfview"
                        src={BACKEND_API_FETCHPDF + "#toolbar=0"}
                        type="application/pdf"
                        scrolling="auto"
                        height="600px"
                        width="1000px"
                    />
                </Row>
            </div>
        );
    }
}

export default InsFAQ;
