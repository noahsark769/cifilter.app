import React from 'react';
import styled, { css } from 'styled-components';

const Title = styled.div`
    font-size: 38px;
    font-weight: bold;
`;

const AvailableContainer = styled.div`
    display: flex;
    flex-direction: row;
    justify-content: flex-end;
`;

const AvailableStack = styled.div`
    display: flex;
    flex-direction: row;
`;

const Available = styled.div`
    padding: 12px;
    color: white;
    background-color: #FF8D8D;

    ${(props) => props.highlighted && css`
        background-color: #74AEDF;
    `};

    font-weight: bold;
    font-size: 14px;
    border-radius: 7px;
`;

const Categories = styled.div`
    font-size: 14px;
    color: #a4a4a4;
    border-bottom: 1px solid #ddd;
    line-height: 20px;
`;

const macSystemName = (version) => {
    const [major, minor] = version.split(".")
    if (Number.parseInt(major) >= 10 && Number.parseInt(minor || "0") >= 12) {
        return "macOS";
    }
    return "OSX";
};

const FilterTitle = (props) => {
    return (
        <div className={props.className} style={props.style}>
            <Title className="margin-bottom--sm">{props.name}</Title>
            <Categories className="padding-bottom--sm margin-bottom--sm">{props.categories.join(", ")}</Categories>
            <AvailableContainer>
                <AvailableStack>
                    <Available highlighted className="margin-right--sm">iOS {props.availableIOS}+</Available>
                    <Available>{macSystemName(props.availableMac)} {props.availableMac}+</Available>
                </AvailableStack>
            </AvailableContainer>
        </div>
    )
};
export default FilterTitle;