import React from 'react';
import styled from 'styled-components';
import FilterTitle from './FilterTitle';

const Container = styled.div`
    width: 700px;
    height: 100%;
    overflow-y: scroll;
    padding-bottom: 48px;
`;

const Description = styled.div`
    font-size: 16px;
    line-height: 22px;
`;

const FilterDetail = (props) => {
    if (!props.filter) {
        return <Container>Ain't nothin here</Container>
    }
    return (
        <Container>
            <FilterTitle
                name={props.filter.name}
                categories={props.filter.categories}
                availableMac={props.filter.availableMac}
                availableIOS={props.filter.availableIOS}
                className="margin-bottom--md" />
            <Description>{props.filter.description}</Description>
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