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

const DescriptionContainer = styled.div`
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    flex: 3;
`;

const Description = styled.div`
    font-size: 16px;
    line-height: 20px;

    ${(props) => props.longType && css`
        flex: 5;
    `};

    ${(props) => props.italic && css`
        font-style: italic;
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

const Info = styled.div`
    color: #666;
    font-size: 13px;
    font-style: italic;
    margin-top: 12px;
`;

const FilterParameter = (props) => {
    console.log(props)
    return (
        <Container>
            <TypeContainer longType={props.longType}>
                <ParameterName className="margin-bottom--sm">{props.parameter.name}</ParameterName>
                <ParameterClass>{props.parameter.classType}</ParameterClass>
            </TypeContainer>
            <DescriptionContainer>
                <Description longType={props.longType} italic={!props.parameter.description}>{props.parameter.description || "No description provided by Core Image."}</Description>
                {props.parameter.type.information && <Info>Type: {props.parameter.type.information}</Info>}
            </DescriptionContainer>
        </Container>
    )
};
export default FilterParameter;