import React from 'react';
import styled from 'styled-components';
import Image from './Image';

const Name = styled.div`
    font-size: 12px;
    font-weight: bold;
    color: #999;
    margin-bottom: 10px;
`;

// https://stackoverflow.com/questions/35361986/css-gradient-checkerboard-pattern
const ImageContainer = styled.div`
    border: 1px solid #ddd;
    background-image: linear-gradient(45deg, #eee 25%, transparent 25%), linear-gradient(-45deg, #eee 25%, transparent 25%), linear-gradient(45deg, transparent 75%, #eee 75%), linear-gradient(-45deg, transparent 75%, #eee 75%);
    background-size: 20px 20px;
    background-position: 0 0, 0 10px, 10px -10px, -10px 0px;
`;

const FilterExampleImage = (props) => {
    return (
        <div className={props.className}>
            <Name>{props.name}</Name>
            <ImageContainer><Image filename={props.filename} /></ImageContainer>
        </div>
    )
};
export default FilterExampleImage;