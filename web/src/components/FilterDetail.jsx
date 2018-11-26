import React from 'react';
import styled from 'styled-components';

const Container = styled.div`
    width: 700px;
    height: 100%;
    overflow-y: scroll;
    padding-bottom: 48px;
`;

const Title = styled.div`
    font-size: 38px;
    font-weight: bold;
`;

const FilterDetail = (props) => {
    if (!props.filter) {
        return <Container>Ain't nothin here</Container>
    }
    return (
        <Container>
            <Title>{props.filter.name}</Title>
            <p>{props.filter.description}</p>
            <p>Available iOS: {props.filter.availableIOS}</p>
            <p>Available Mac: {props.filter.availableMac}</p>
            <h3 className="margin-top--md">Categories</h3>
            <ul>
                {props.filter.categories.map((category) => {
                    return <li className="margin-left--sm" key={category}>{category}</li>
                })}
            </ul>
            <h3 className="margin-top--md">Parameters</h3>
            <ul>
                {props.filter.parameters.map((param) => {
                    return <li className="margin-left--sm" key={param.name}>
                        <h4 className="margin-top--sm">{param.name}</h4>
                        <div>Class: {param.classType}</div>
                        <div>Description: {param.description || "No description provided."}</div>
                    </li>
                })}
            </ul>
        </Container>
    )
};
export default FilterDetail;