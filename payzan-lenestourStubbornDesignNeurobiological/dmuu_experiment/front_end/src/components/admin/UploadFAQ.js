/**
 * Upload FAQ to the backend
 */
import axios from "axios";
import React, { Component } from "react";
import { Row, Button } from "react-bootstrap";
import { BACKEND_API_PDFNAME } from "../../backend_interface/backend_url";
import { uploadPDF } from "../../backend_interface/pdf/uploadPDF";

const NO_FILE_UPLOADED = "No file uploaded";
export default class UploadFAQ extends Component {
    state = {
        selectedFile: null,
        isFilePicked: false,
        fileName: NO_FILE_UPLOADED,
    };

    componentDidMount() {
        this.getPDFName();
    }

    getPDFName = () => {
        axios
            .get(BACKEND_API_PDFNAME)
            .then((request) => {
                this.setState({ fileName: request.data.file_name });
            })
            .catch(() => {
                this.setState({ fileName: "Error getting filename" });
            });
    };

    fileChangeHandler = (e) => {
        this.setState({
            selectedFile: e.target.files[0],
            isFilePicked: true,
        });
    };

    handleUpload = () => {
        uploadPDF(this.state.selectedFile, this.getPDFName);
    };

    render() {
        return (
            <>
                <Row className="mt-5">
                    <h5>
                        Upload PDF file. Make sure it is in pdf format or upload
                        will fail
                    </h5>
                </Row>
                <Row>
                    <p>Current file uploaded: <b>{this.state.fileName}</b></p>
                </Row>
                <Row>
                    <input
                        type="file"
                        name="file"
                        onChange={this.fileChangeHandler}
                    />
                </Row>
                <Row className="mt-3">
                    <Button onClick={this.handleUpload}>Upload FAQ PDF</Button>
                </Row>
            </>
        );
    }
}
