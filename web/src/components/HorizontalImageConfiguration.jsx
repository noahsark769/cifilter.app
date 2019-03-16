import React from 'react';
import styled from 'styled-components';
import { IoIosArrowRoundForward } from 'react-icons/io';
import FilterExampleImage from './FilterExampleImage';

const ImageList = styled.div`
    display: flex;
    flex-direction: ${props => props.column ? "column" : "row"};
`;

const Wrapper = styled.div`
    flex: 4;
    &:first-child {
        margin-right: 20px;
    }
`;

const ArrowContainer = styled.div`
    flex: 1;
    display: flex;
    flex-direction: column;
    justify-content: center;
    margin: 0 20px;
`;

/**
 * Displays image parameter values in a horizontal row. Useful for SourceInCompositing etc
 * which take only images as input.
 */
const HorizontalImageConfiguration = (props) => {
    return (
        <ImageList>
            {props.parameterValues.map((value) => {
                const {name, type, additionalData} = value;
                if (type !== "image") { return null; }
                if (name === "outputImage") { return null; }
                return (
                    <Wrapper key={name}>
                        <FilterExampleImage
                            name={name}
                            filename={`${props.basepath}/${additionalData.image}`}
                        />
                    </Wrapper>);
            })}
            <ArrowContainer>
                <IoIosArrowRoundForward size={50} color="#999" />
            </ArrowContainer>
            <Wrapper>
                <FilterExampleImage
                    name="outputImage"
                    filename={`${props.basepath}/${props.outputImageData.image}`}
                />
                <WasCropped wasCropped={props.outputImageData.wasCropped} />
            </Wrapper>
        </ImageList>
    );
};
export default HorizontalImageConfiguration;

export const WasCropped = (props) => {
    if (props.wasCropped) {
        return (<span>Note: this example image was cropped since the original outputImage had infinite extent.</span>)
    }
    return null;
};