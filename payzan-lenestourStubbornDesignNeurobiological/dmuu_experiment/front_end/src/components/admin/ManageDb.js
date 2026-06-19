/**
 * Manage sqlite3 db on the backend
 */
import React, { Component } from "react";
import { Row, Button } from "react-bootstrap";
import { uploadDb, downloadDb } from "../../backend_interface/sqlitedb/sqlitedb";

export default class ManageDb extends Component {
    state = {
        selectedFile: null,
        isFilePicked: false,
    };

    fileChangeHandler = (e) => {
        this.setState({
            selectedFile: e.target.files[0],
            isFilePicked: true,
        });
    };

    handleUpload = () => {
        if (this.state.isFilePicked)
            uploadDb(this.state.selectedFile);
    };

    render() {
        return (
            <>
                <Row className="mt-5">
                    <input
                        type="file"
                        name="file"
                        onChange={this.fileChangeHandler}
                    />
                </Row>
                <Row className="mt-3">
                    <Button onClick={this.handleUpload}>Upload sqlite db</Button>
                </Row>
                <Row className="mt-3">
                    <Button onClick={downloadDb}>Download sqlite db</Button>
                </Row>
            </>
        );
    }
}
