import React, { Component } from "react";
import { Container, Table, Button, Modal, Row } from "react-bootstrap";
import axios from "axios";
import moment from "moment";
import
{
    BACKEND_API_DELETE,
    BACKEND_API_EMAILRESET,
    BACKEND_API_LIST,
    BACKEND_API_QGET,
    BACKEND_API_ZIPXLS,
    BACKEND_API_ZIPXLSALL,
    BACKEND_API_FETCHXLS 
}
from "../../backend_interface/backend_url";
import loaderSrc from '../loader/loader.svg';

const download_file = (request, type, dl_file_name) => {
    const url = window.URL.createObjectURL(
        new Blob([request.data], {type})
    );
    const link = document.createElement("a");
    link.href = url;
    link.setAttribute("download", dl_file_name);
    document.body.appendChild(link);
    link.click();
    URL.revokeObjectURL(url);
}
export default class Experiments extends Component {
    constructor(props) {
        super(props);
        this._mounted = false;
    }

    state = {
        data: null,
        loaded: false,
        showModal: false,
        idToDelete: null,
        emailToDelete: null,
        hideDownloaded: true,
        downloadingZip: false
    };

    handleShowDeleteConfirm = (id, email) => {
        this.setState({ showModal: true, idToDelete: id, emailToDelete: email });
    };

    handleCloseDeleteConfirm = () => {
        this.setState({ showModal: false, idToDelete: null, emailToDelete: null });
    };

    getListExperiments = () => {
        axios
            .get(BACKEND_API_LIST)
            .then((request) => {
                if (this._mounted)
                    this.setState({ data: request.data, loaded: true });
            })
            .catch((err) => console.log(err));
    };

    downloadXLS = (id, email) => {
        axios
            .get(BACKEND_API_FETCHXLS + "/" + id, {
                responseType: "arraybuffer",
            })
            .then((res) => {
                download_file(res, "application/vnd.ms-excel", email + "_experiment_results_id-" + id + ".xls");
                this.getListExperiments();
            })
            .catch((err) => console.log(err));
    };

    downloadZipAll = () => {
        this.setState({downloadingZip: true}, () => {
            axios
                .get(BACKEND_API_ZIPXLSALL, {
                    responseType: "arraybuffer",
                })
                .then((res) => {
                    download_file(res, "application/zip", "all_experiments.zip");
                    this.setState({downloadingZip: false}, () => {
                        this.getListExperiments();
                    });
                })
                .catch((err) => {
                    console.log(err);
                    this.setState({downloadingZip: false});
                });
        });
    };

    downloadZipUnviewed = () => {
        this.setState({downloadingZip: true}, () => {
            axios
                .get(BACKEND_API_ZIPXLS, {
                    responseType: "arraybuffer",
                })
                .then((res) => {
                    download_file(res, "application/zip", "new_experiments.zip");
                    this.setState({downloadingZip: false}, () => {
                        this.getListExperiments();
                    });
                })
                .catch((err) => {
                    console.log(err);
                    this.setState({downloadingZip: false});
                });
        });
    };

    downloadQuestionnaire = (email) => {
        axios
            .post(
                BACKEND_API_QGET,
                { email: email },
                { responseType: "arraybuffer" }
            )
            .then((res) => {
                download_file(res, "application/vnd.ms-excel", email + "_questionnaire_results.xls");
            })
            .catch((err) => console.log(err));
    };

    handleDeleteEntry = () => {
        this.deleteEntry(this.state.idToDelete, this.state.emailToDelete);
        this.handleCloseDeleteConfirm();
    };

    resetEmail = (email) => {
        axios
            .post(BACKEND_API_EMAILRESET, { email: email })
            .then((request) => {
                console.log(request.data.message);
                this.getListExperiments();
            })
            .catch((err) => console.log(err));
    };

    deleteEntry = (id, email) => {
        axios
            .post(BACKEND_API_DELETE + "/" + id)
            .then((request) => {
                this.resetEmail(email);
            })
            .catch((err) => console.log(err));
    };

    handleShowAll = () => {
        this.setState({ hideDownloaded: false });
    };

    handleHideDl = () => {
        this.setState({ hideDownloaded: true });
    };

    displayEntry = (element) => {
        if (this.state.hideDownloaded && element.viewed)
            return;
        return (
            <tr key={element.id}>
                <td>{element.id}</td>
                <td>{element.first_name}</td>
                <td>{element.last_name}</td>
                <td>{element.email}</td>
                <td>{element.experiment_type}</td>
                <td>{element.status}</td>
                <td>
                    {moment
                        .utc(element.date_completed)
                        .local()
                        .format("DD-MM-YYYY HH:mm")}
                </td>
                <td>{element.viewed ? "Downloaded" : "New"}</td>
                <td>
                    <Button
                        onClick={() =>
                            this.downloadXLS(element.id, element.email)
                        }
                    >
                        Experiment Results
                    </Button>
                </td>
                <td>
                    <Button
                        onClick={() =>
                            this.downloadQuestionnaire(element.email)
                        }
                    >
                        Questionnaire Results
                    </Button>
                </td>
                <td>
                    <Button
                        onClick={() =>
                            this.handleShowDeleteConfirm(
                                element.id,
                                element.email
                            )
                        }
                    >
                        Delete
                    </Button>
                </td>
            </tr>
        );
    };

    componentDidMount() {
        this.getListExperiments();
        this._mounted = true;
    }

    componentWillUnmount() {
        this._mounted = false;
    }

    renderExperiments = () => {
        if (this.state.loaded) {
            return (
                <>
                    <Row className="mt-2 mb-2">
                        <h5 className="ml-5">Filter experiments:</h5>
                        <Button onClick={this.handleShowAll} className="ml-5">Show all</Button>
                        <Button onClick={this.handleHideDl} className="ml-5">Hide downloaded</Button>
                        <h5 className="ml-5">Download as zip:</h5>
                        <Button onClick={this.downloadZipAll} className="ml-5">All</Button>
                        <Button onClick={this.downloadZipUnviewed} className="ml-5">Only undownloaded</Button>
                    </Row>
                    <Row className="justify-content-center">
                        {
                            this.state.downloadingZip &&
                            <Row className="align-items-center">
                                <h4>Downloading zip please wait...</h4>
                                <img src={loaderSrc} height="50%" alt=""/>
                            </Row>
                        }
                    </Row>
                    <Table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>First Name</th>
                                <th>Last Name</th>
                                <th>Email</th>
                                <th>Experiment Type</th>
                                <th>Status</th>
                                <th>Last Updated</th>
                                <th>Downloaded</th>
                                <th>Experiment Results</th>
                                <th>Questionnaire Results</th>
                                <th>Delete</th>
                            </tr>
                        </thead>
                        <tbody>
                            {this.state.data.map((element) => this.displayEntry(element))}
                        </tbody>
                    </Table>
                    <Modal
                        show={this.state.showModal}
                        onHide={this.handleCloseDeleteConfirm}
                        animation={false}
                    >
                        <Modal.Header closeButton>
                            <Modal.Title>Confirm deletion</Modal.Title>
                        </Modal.Header>
                        <Modal.Body>
                            Are you sure you want to delete experiment data for {this.state.emailToDelete}? 
                            Deleted experiments will be lost forever.
                        </Modal.Body>
                        <Modal.Footer>
                            <Button onClick={this.handleCloseDeleteConfirm}>
                                No
                            </Button>
                            <Button onClick={this.handleDeleteEntry}>
                                Yes
                            </Button>
                        </Modal.Footer>
                    </Modal>
                </>
            );
        }
    };

    render() {
        return <Container>{this.renderExperiments()}</Container>;
    }
}
