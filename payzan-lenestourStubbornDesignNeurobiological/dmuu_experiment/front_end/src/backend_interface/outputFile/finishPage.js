// Sends the finish page data using axios
import axios from "axios";
import { BACKEND_API_SETFINISH } from "../backend_url";
import axiosRetry from "axios-retry";

const RETRY_DELAY = 1000;
const NUM_RETRIES = 300;

export function sendFinishPageToBackend(data, func=null) {
    axiosRetry(axios, {retries: NUM_RETRIES, retryDelay: (retries) => {
        console.log(`Failed to connect: ${retries}`);
        return RETRY_DELAY;
    }});
    axios
        .post(BACKEND_API_SETFINISH, data)
        .then((res) => {
            console.log(res.data.message);
            if (func) func();
        })
        .catch(() => console.log("Failed to send finish to backend"));
}
