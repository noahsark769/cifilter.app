import React from 'react';
import styled, { css } from 'styled-components';

const Container = styled.div`
    display: flex;
    flex-direction: row;

    margin-bottom: 36px;
`;

const TypeContainer = styled.div`
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    margin-right: 24px;

    ${(props) => props.longType && css`
        flex: 3
    `};
`;

const Description = styled.div`
    flex: 3;
    font-size: 16px;
    line-height: 20px;

    ${(props) => props.longType && css`
        flex: 5;
    `};
`;

const ParameterName = styled.div`
    font-size: 14px;
    color: #666;
    font-style: italic;
`;

const ParameterClass = styled.div`
    color: #666;
    font-size: 16px;
    font-family: monospace;
`;

const FilterParameter = (props) => {
    return (
        <Container>
            <TypeContainer longType={props.longType}>
                <ParameterName className="margin-bottom--sm">{props.parameter.name}</ParameterName>
                <ParameterClass>{props.parameter.classType}</ParameterClass>
            </TypeContainer>
            <Description longType={props.longType}>{props.parameter.description || "No description provided by Core Image."}</Description>
        </Container>
    )
};
export default FilterParameter;