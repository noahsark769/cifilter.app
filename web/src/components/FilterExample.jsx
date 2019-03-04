import React from 'react';
import styled from 'styled-components';
import FilterExampleImage from './FilterExampleImage';
import FilterDetailSectionHeading from './FilterDetailSectionHeading';
import { IoIosArrowRoundForward } from 'react-icons/io';

const ImageList = styled.div`
    display: flex;
    flex-direction: row;
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

const WasCropped = (props) => {
    if (props.wasCropped) {
        return (<span>Note: this example image was cropped since the original outputImage had infinite extent.</span>)
    }
    return null;
};

const HorizontalImageConfiguration = (props) => {
    return (
        <ImageList>
            {props.parameterValues.map((value) => {
                const {name, type, additionalData} = value;
                if (type !== "image") { return null; }
                if (name === "outputImage") { return null; }
                return (
                    <Wrapper>
                        <FilterExampleImage
                            key={name}
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

const FilterExample = (props) => {
    console.log(props);
    const outputImageData = props.example.data.parameterValues.filter(
        ({ name }) => name === 'outputImage'
    )[0];

    const nonImageParameters = props.example.data.parameterValues.filter(({ type }) => type !== "image");
    const imageParameters = props.example.data.parameterValues.filter(
        ({ type, name }) => type === "image" && name !== "outputImage"
    );

    let rendered;
    if (nonImageParameters.length == 0 && imageParameters.length == 2) {
        rendered = (<HorizontalImageConfiguration
            basepath={props.example.basepath}
            outputImageData={outputImageData.additionalData}
            parameterValues={props.example.data.parameterValues}
            />);
    } else {
        rendered = (<HorizontalImageConfiguration
            basepath={props.example.basepath}
            outputImageData={outputImageData.additionalData}
            parameterValues={props.example.data.parameterValues}
            />); 
    }

    return (
        <>
            <FilterDetailSectionHeading>Example</FilterDetailSectionHeading>
            {rendered}
        </>
    );
};
export default FilterExample;