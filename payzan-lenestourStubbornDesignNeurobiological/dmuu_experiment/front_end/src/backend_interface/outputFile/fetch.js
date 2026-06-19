// FIXME: Does not work since setState needs to be inside a class, would be nicer to modularize
// Fetch the saved experiments
import axios from "axios";
import { BACKEND_API_LIST } from "../backend_url";

// Get a list
export function getListExperiments(setState) {
    axios
        .get(BACKEND_API_LIST)
        .then((request) => {
            setState({data: request.data});
        })
        .catch((err) => console.log(err));
}
