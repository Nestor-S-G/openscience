import loaderSrc from './loader.svg';

import React from 'react';

export default function Loader() {
    return (
        <div className="d-flex justify-content-center align-items-center h-100">
            <div>
                <div className="row align-items-center">
                    <img src={loaderSrc} alt="Loading..."/>
                    <h1 className="pl-4">Loading...</h1>
                </div>
                <div className="row pt-5">
                    <p>Please wait. Thank you for your patience.</p>
                </div>
                <div className="row">
                    <p>Taking too long? Check internet connection.</p>
                </div>
                <div className="row">
                    <p>Otherwise contact BizLabs or the experimenter.</p>
                </div>
            </div>
        </div>
    )
}
